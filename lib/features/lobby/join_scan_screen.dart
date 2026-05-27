import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/session_providers.dart';
import '../../core/bluetooth/ble_service.dart';
import '../../core/game/lobby_state.dart';
import '../../core/models/player_slot.dart';
import '../../core/network/session_join_uri.dart';
import '../../core/network/ws_client_service.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import 'deck_picker_sheet.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
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
      _showSnackbar('Not a valid MTG Life Spark QR code.', isError: true);
    }
  }

  // ── Connection ────────────────────────────────────────────────────────────

  Future<void> _connectTo(String wsUri, {required String joinToken}) async {
    await _stopScanner();
    if (!mounted) return;
    setState(() => _phase = _JoinPhase.connecting);

    final client = _client;
    if (client == null) {
      _showSnackbar(
        'Could not start join session. Finish profile setup and try again.',
        isError: true,
      );
      _resetToScan();
      return;
    }

    _connectionSub = ref
        .read(sessionServiceProvider)!
        .connectionStream
        .listen(_onConnectionEvent);

    await client.connectToHost(wsUri, joinToken: joinToken);
  }

  void _onConnectionEvent(BleConnectionEvent event) {
    if (!mounted) return;
    switch (event.status) {
      case BleConnectionStatus.connected:
        unawaited(_stopScanner());
        ref.read(lobbyProvider.notifier).initAsClient();
        setState(() => _phase = _JoinPhase.waitingRoom);

      case BleConnectionStatus.rejected:
        _showSnackbar(
          event.errorMessage ?? 'Host rejected connection (version mismatch).',
          isError: true,
        );
        _resetToScan();

      case BleConnectionStatus.disconnected:
        if (_phase == _JoinPhase.waitingRoom) {
          _showSnackbar('Disconnected from host.');
          _resetToScan();
        }

      case BleConnectionStatus.error:
        _showSnackbar(event.errorMessage ?? 'Connection error.', isError: true);
        _resetToScan();

      default:
        break;
    }
  }

  Future<void> _resetToScan() async {
    await _stopScanner();
    if (!mounted) return;
    setState(() {
      _phase = _JoinPhase.scanning;
      _scanned = false;
    });
    await _syncCameraPermission();
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    final colors = AppColorTokens.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? ColorTokens.danger : colors.surface,
    ));
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
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _stopScanner();
            await endSession(ref);
            if (context.mounted) context.go(AppRoutes.home);
          },
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Stack(
      children: [
        MobileScanner(controller: controller, onDetect: onDetect),
        // Overlay with cut-out guide
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: colors.primaryAccent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Text(
            'Point the camera at the host\'s QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorTokens.onAccent,
              fontSize: FontTokens.body,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 64, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Camera access is needed to scan the host QR code.\n'
              'If you already allowed it in Settings, tap Try again.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: colors.textSecondary, fontSize: FontTokens.body),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => unawaited(onRetry()),
              child: Text('Try again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => unawaited(openAppSettings()),
              child: Text('Open Settings'),
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
          const SizedBox(height: 20),
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
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<LobbyState>(lobbyProvider, (previous, next) {
      if (next.isGameStarted && !(previous?.isGameStarted ?? false)) {
        if (!context.mounted) return;
        context.go(AppRoutes.game);
      }
    });

    final lobby = ref.watch(lobbyProvider);

    final colors = AppColorTokens.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Waiting for host to start…',
                style: TextStyle(
                    color: colors.textSecondary, fontSize: FontTokens.label),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...lobby.players.map((slot) => _WaitingSlotRow(slot: slot)),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final profile =
                          ref.read(profileRepositoryProvider).getProfile();
                      if (profile == null) return;
                      showDeckPickerSheet(context, ref, profile.username);
                    },
                    child: Text('Deck'),
                  ),
                  OutlinedButton.icon(
                    icon: Icon(Icons.style),
                    label: Text('Commander'),
                    onPressed: () {
                      final profile =
                          ref.read(profileRepositoryProvider).getProfile();
                      if (profile == null) return;
                      context.push(AppRoutes.commanderSelect, extra: {
                        'playerId': profile.username,
                        'hasPartner': lobby.players
                            .firstWhere(
                              (p) => p.playerId == profile.username,
                              orElse: () => lobby.players.first,
                            )
                            .hasPartner,
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size(
                    LayoutTokens.minTapTarget,
                    LayoutTokens.minTapTarget,
                  ),
                  backgroundColor:
                      _isReady
                          ? colors.primaryAccent.withValues(
                            alpha: OpacityTokens.soft,
                          )
                          : colors.surface,
                  foregroundColor:
                      _isReady ? colors.primaryAccent : colors.textSecondary,
                  side: BorderSide(
                    color:
                        _isReady
                            ? colors.primaryAccent
                            : colors.textSecondary,
                  ),
                ),
                onPressed: () {
                  setState(() => _isReady = !_isReady);
                  ref
                      .read(lobbyProvider.notifier)
                      .sendReadyToHost(ready: _isReady);
                },
                icon: Icon(Icons.check_rounded, size: 32),
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: Row(
        children: [
          if (slot.commanderImageUrl != null)
            ClipRRect(
              borderRadius: RadiusTokens.radiusXs,
              child: CachedNetworkImage(
                imageUrl: slot.commanderImageUrl!,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _dot(slot.playerColor),
              ),
            )
          else
            _dot(slot.playerColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.username,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (slot.commanderName != null)
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
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (slot.isReady ? colors.primaryAccent : colors.textSecondary)
                      .withValues(alpha: 0.15),
              borderRadius: RadiusTokens.radiusXs,
              border: Border.all(
                color:
                    slot.isReady
                        ? colors.primaryAccent
                        : colors.textSecondary,
              ),
            ),
            child: Text(
              slot.isReady ? 'Ready' : 'Waiting',
              style: TextStyle(
                color:
                    slot.isReady
                        ? colors.primaryAccent
                        : colors.textSecondary,
                fontSize: FontTokens.sm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: RadiusTokens.radiusXs,
          border: Border.all(color: color),
        ),
        child: Icon(Icons.person, color: color, size: 20),
      );
}
