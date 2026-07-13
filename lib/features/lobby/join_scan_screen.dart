import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/session_providers.dart';
import '../../core/bluetooth/ble_service.dart';
import '../../core/game/game_format.dart';
import '../../core/game/lobby_state.dart';
import '../../core/models/player_slot.dart';
import '../../core/network/session_join_uri.dart';
import '../../core/network/ws_client_service.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/session_leave_dialog.dart';
import 'deck_picker_sheet.dart';
import 'lobby_slot_widgets.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/components/ui_snack_bar.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/components/ui_app_bar.dart';

enum _JoinPhase { scanning, connecting, waitingRoom }

class JoinScanScreen extends ConsumerStatefulWidget {
  const JoinScanScreen({super.key});

  @override
  ConsumerState<JoinScanScreen> createState() => _JoinScanScreenState();
}

class _JoinScanScreenState extends ConsumerState<JoinScanScreen>
    with WidgetsBindingObserver {
  _JoinPhase _phase = _JoinPhase.scanning;
  bool _cameraPermissionGranted = false;
  bool _scanned = false;
  int _connectAttempt = 0;
  Timer? _connectTimeout;

  StreamSubscription<BleConnectionEvent>? _connectionSub;
  MobileScannerController? _scannerController;

  WsClientService? get _client {
    final svc = ref.read(sessionServiceProvider);
    return svc is WsClientService ? svc : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectTimeout?.cancel();
    _connectionSub?.cancel();
    unawaited(_stopScanner());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _phase == _JoinPhase.scanning &&
        mounted) {
      unawaited(_syncCameraPermission());
    }
  }

  /// Creates the scanner controller; [MobileScanner] starts the camera once mounted.
  void _ensureScannerController() {
    if (!_cameraPermissionGranted || _scannerController != null) return;
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  /// Fully releases the camera when leaving the QR scan step.
  Future<void> _stopScanner() async {
    final controller = _scannerController;
    if (controller == null) return;
    _scannerController = null;
    try {
      await controller.stop();
    } catch (_) {
      // Already stopped or detached.
    }
    try {
      await controller.dispose();
    } catch (_) {
      // Controller may already be disposed.
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<bool> _syncCameraPermission({bool requestIfNeeded = false}) async {
    var status = await Permission.camera.status;
    if (!status.isGranted &&
        !status.isLimited &&
        requestIfNeeded &&
        !status.isPermanentlyDenied) {
      status = await Permission.camera.request();
    }
    if (!mounted) return false;

    final granted = status.isGranted || status.isLimited;
    if (granted) {
      if (!_cameraPermissionGranted) {
        setState(() => _cameraPermissionGranted = true);
      } else {
        setState(() {});
      }
      _ensureScannerController();
      final controller = _scannerController;
      if (controller != null && controller.value.isInitialized) {
        try {
          await controller.start();
        } catch (_) {
          // MobileScanner will retry on the next resume/build cycle.
        }
      }
      return true;
    }

    if (_cameraPermissionGranted || _scannerController != null) {
      await _stopScanner();
      if (mounted) {
        setState(() => _cameraPermissionGranted = false);
      }
    } else if (mounted) {
      setState(() => _cameraPermissionGranted = false);
    }
    return false;
  }

  Future<void> _init() async {
    final granted = await _syncCameraPermission(requestIfNeeded: true);
    if (!mounted) return;

    if (granted) {
      await startClientSession(ref);
      ref.read(lobbyProvider.notifier).initAsClient();
    } else {
      _showSnackbar(
        'Camera permission is required to scan the host QR code.',
        isError: true,
      );
    }
  }

  // ── QR code handling ──────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_scanned || _phase != _JoinPhase.scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null) return;

    try {
      final parsed = SessionJoinUri.parse(raw);
      if (parsed.token == null || parsed.token!.isEmpty) {
        _showSnackbar(
          'This QR code is missing a join token. Ask the host to refresh their QR.',
          isError: true,
        );
        return;
      }
      _scanned = true;
      unawaited(_stopScanner().then((_) {
        if (mounted) {
          _connectTo(parsed.wsUri, joinToken: parsed.token!);
        }
      }));
    } on FormatException {
      _showSnackbar('Not a valid Life Spark QR code.', isError: true);
    }
  }

  // ── Connection ────────────────────────────────────────────────────────────

  Future<void> _cancelConnectAttempt() async {
    _connectAttempt++;
    _connectTimeout?.cancel();
    _connectTimeout = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    await _client?.disconnect();
  }

  Future<void> _connectTo(String wsUri, {required String joinToken}) async {
    await _stopScanner();
    if (!mounted) return;

    final attempt = ++_connectAttempt;
    setState(() => _phase = _JoinPhase.connecting);

    final client = _client;
    if (client == null) {
      _showSnackbar(
        'Could not start join session. Finish profile setup and try again.',
        isError: true,
      );
      await _resetToScan();
      return;
    }

    await _connectionSub?.cancel();
    _connectionSub = ref
        .read(sessionServiceProvider)!
        .connectionStream
        .listen(_onConnectionEvent);

    _connectTimeout?.cancel();
    _connectTimeout = Timer(const Duration(seconds: 15), () {
      unawaited(_onConnectTimedOut(attempt));
    });

    await client.connectToHost(wsUri, joinToken: joinToken);
    if (!mounted || attempt != _connectAttempt) return;
  }

  Future<void> _onConnectTimedOut(int attempt) async {
    if (!mounted || attempt != _connectAttempt) return;
    if (_phase != _JoinPhase.connecting) return;
    _showSnackbar(
      'Timed out connecting to the host. Make sure you are on the same Wi‑Fi '
      'and the host lobby is still open, then try again.',
      isError: true,
    );
    await _resetToScan();
  }

  void _onConnectionEvent(BleConnectionEvent event) {
    if (!mounted) return;
    switch (event.status) {
      case BleConnectionStatus.connected:
        _connectTimeout?.cancel();
        _connectTimeout = null;
        unawaited(_stopScanner());
        setState(() => _phase = _JoinPhase.waitingRoom);

      case BleConnectionStatus.rejected:
        _connectTimeout?.cancel();
        _connectTimeout = null;
        _showSnackbar(
          event.errorMessage ?? 'Host rejected connection (version mismatch).',
          isError: true,
        );
        unawaited(_resetToScan());

      case BleConnectionStatus.disconnected:
        if (_phase == _JoinPhase.waitingRoom) {
          _showSnackbar('Disconnected from host.');
          unawaited(_resetToScan());
        }

      case BleConnectionStatus.error:
        _connectTimeout?.cancel();
        _connectTimeout = null;
        _showSnackbar(event.errorMessage ?? 'Connection error.', isError: true);
        unawaited(_resetToScan());

      default:
        break;
    }
  }

  Future<void> _resetToScan() async {
    await _cancelConnectAttempt();
    await _stopScanner();
    if (!mounted) return;
    setState(() {
      _phase = _JoinPhase.scanning;
      _scanned = false;
    });
    await _syncCameraPermission();
  }

  Future<void> _leaveJoinFlow() async {
    final needsConfirm = _phase == _JoinPhase.connecting ||
        _phase == _JoinPhase.waitingRoom;
    if (needsConfirm) {
      final ok = await confirmLeaveActiveSession(context);
      if (!ok || !mounted) return;
    }
    await _cancelConnectAttempt();
    await _stopScanner();
    await endSession(ref);
    if (mounted) context.pop();
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    showUiSnackBar(context, msg, isError: isError);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: UiAppBar(
        title: 'Join a Game',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Leave',
          onPressed: () => unawaited(_leaveJoinFlow()),
        ),
      ),
      body: switch (_phase) {
        _JoinPhase.scanning =>
          _cameraPermissionGranted && _scannerController != null
              ? _QrScanView(
                  controller: _scannerController!,
                  onDetect: _onDetect,
                )
              : _PermissionDeniedView(
                  onRetry: () => _syncCameraPermission(requestIfNeeded: true),
                ),
        _JoinPhase.connecting => const _ConnectingView(),
        _JoinPhase.waitingRoom => const _WaitingRoomView(),
      },
    );
  }
}

// ── QR scan view ──────────────────────────────────────────────────────────

class _QrScanView extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  const _QrScanView({required this.controller, required this.onDetect});

  static const double _cutoutSize = 240;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: controller, onDetect: onDetect),
        CustomPaint(
          painter: _QrScanOverlayPainter(
            cutoutSize: _cutoutSize,
            accent: colors.primaryAccent,
            dimColor: Colors.black.withValues(alpha: 0.58),
          ),
        ),
        Positioned(
          bottom: 48,
          left: LayoutTokens.gr4,
          right: LayoutTokens.gr4,
          child: Text(
            'Point the camera at the host\'s QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorTokens.onAccent,
              fontSize: FontTokens.body,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
        ),
      ],
    );
  }
}

class _QrScanOverlayPainter extends CustomPainter {
  const _QrScanOverlayPainter({
    required this.cutoutSize,
    required this.accent,
    required this.dimColor,
  });

  final double cutoutSize;
  final Color accent;
  final Color dimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    final cutout = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(RadiusTokens.md),
    );

    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, Paint()..color = dimColor);

    const arm = 28.0;
    const stroke = 4.0;
    final paint = Paint()
      ..color = accent
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * arm, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy * arm), paint);
    }

    corner(cutoutRect.topLeft, 1, 1);
    corner(cutoutRect.topRight, -1, 1);
    corner(cutoutRect.bottomLeft, 1, -1);
    corner(cutoutRect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _QrScanOverlayPainter oldDelegate) =>
      oldDelegate.cutoutSize != cutoutSize ||
      oldDelegate.accent != accent ||
      oldDelegate.dimColor != dimColor;
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutTokens.gr5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 64, color: colors.textSecondary),
            SizedBox(height: LayoutTokens.gr4),
            Text(
              'Camera access is needed to scan the host QR code.\n'
              'If you already allowed it in Settings, tap Try again.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: colors.textSecondary, fontSize: FontTokens.body),
            ),
            SizedBox(height: LayoutTokens.gr4),
            UiButton(
              label: 'Try again',
              onPressed: () => unawaited(onRetry()),
            ),
            SizedBox(height: LayoutTokens.gr2),
            UiButton(
              label: 'Open Settings',
              variant: UiButtonVariant.secondary,
              onPressed: () => unawaited(openAppSettings()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connecting view ───────────────────────────────────────────────────────

class _ConnectingView extends StatelessWidget {
  const _ConnectingView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.primaryAccent),
          SizedBox(height: LayoutTokens.gr4 + LayoutTokens.gr0),
          Text(
            'Connecting to host…',
            style: TextStyle(color: colors.textSecondary, fontSize: FontTokens.bodyLg),
          ),
        ],
      ),
    );
  }
}

// ── Waiting room ──────────────────────────────────────────────────────────

class _WaitingRoomView extends ConsumerStatefulWidget {
  const _WaitingRoomView();

  @override
  ConsumerState<_WaitingRoomView> createState() => _WaitingRoomViewState();
}

class _WaitingRoomViewState extends ConsumerState<_WaitingRoomView> {
  @override
  Widget build(BuildContext context) {
    ref.listen<LobbyState>(lobbyProvider, (previous, next) {
      if (next.isGameStarted && !(previous?.isGameStarted ?? false)) {
        if (!context.mounted) return;
        context.go(AppRoutes.game);
      }
    });

    final lobby = ref.watch(lobbyProvider);
    final profile = ref.read(profileRepositoryProvider).getProfile();
    PlayerSlot? mySlot;
    if (profile != null) {
      for (final slot in lobby.players) {
        if (slot.playerId == profile.username) {
          mySlot = slot;
          break;
        }
      }
    }

    final colors = AppColorTokens.of(context);
    final isCommanderLobby = lobby.config.format.isCommanderStyle;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: LayoutTokens.shellListPadding(context),
            children: [
              Text(
                'Waiting for host to start…',
                style: TextStyle(
                    color: colors.textSecondary, fontSize: FontTokens.label),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: LayoutTokens.gr3),
              ...lobby.players.map((slot) => _WaitingSlotRow(slot: slot)),
              if (profile != null) ...[
                SizedBox(height: LayoutTokens.shellSectionGap),
                if (isCommanderLobby)
                  Row(
                    children: [
                      Expanded(
                        child: LobbyActionButton(
                          label: 'Select deck',
                          highlighted: mySlot?.selectedDeckId != null,
                          onPressed: () => showDeckPickerSheet(
                            context,
                            ref,
                            profile.username,
                          ),
                        ),
                      ),
                      SizedBox(width: LayoutTokens.gr2),
                      Expanded(
                        child: LobbyActionButton(
                          label: 'Select commander',
                          highlighted: mySlot?.commanderName != null,
                          filled: true,
                          onPressed: () {
                            context.push(AppRoutes.commanderSelect, extra: {
                              'playerId': profile.username,
                            });
                          },
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: LobbyActionButton(
                      label: 'Select deck',
                      highlighted: mySlot?.selectedDeckId != null,
                      filled: true,
                      onPressed: () => showDeckPickerSheet(
                        context,
                        ref,
                        profile.username,
                      ),
                    ),
                  ),
                SizedBox(height: LayoutTokens.gr2),
                SizedBox(
                  width: double.infinity,
                  child: LobbyActionButton(
                    label: mySlot?.isReady == true ? 'Ready' : 'Mark ready',
                    highlighted: mySlot?.isReady == true,
                    filled: true,
                    onPressed: () {
                      final ready = !(mySlot?.isReady ?? false);
                      ref
                          .read(lobbyProvider.notifier)
                          .sendReadyToHost(ready: ready);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WaitingSlotRow extends StatelessWidget {
  final PlayerSlot slot;
  const _WaitingSlotRow({required this.slot});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return LobbySlotCardShell(
      child: Row(
        children: [
          LobbySlotAvatar(slot: slot, size: 44),
          SizedBox(width: LayoutTokens.gr2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LobbyPlayerIdentityRow(
                  username: slot.username,
                  playerColor: slot.playerColor,
                ),
                if (slot.commanderName != null) ...[
                  SizedBox(height: LayoutTokens.gr1),
                  Text(
                    slot.commanderName!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.caption,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          LobbyReadyBadge(isReady: slot.isReady),
        ],
      ),
    );
  }
}
