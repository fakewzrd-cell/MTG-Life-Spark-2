import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/player_game_state.dart';
import '../../../core/game/scryfall_service.dart';
import '../../../core/persistence/providers.dart';
import '../../../shared/utils/commander_image_resolver.dart';

/// Commander art at reduced opacity behind an overview player row.
/// Resolves deck/profile URLs and fetches Scryfall when missing.
class OverviewCommanderArtBackdrop extends ConsumerStatefulWidget {
  const OverviewCommanderArtBackdrop({
    super.key,
    required this.player,
    this.opacity = 0.25,
  });

  final PlayerGameState player;
  final double opacity;

  @override
  ConsumerState<OverviewCommanderArtBackdrop> createState() =>
      _OverviewCommanderArtBackdropState();
}

class _OverviewCommanderArtBackdropState
    extends ConsumerState<OverviewCommanderArtBackdrop> {
  String? _resolvedUrl;
  bool _fetchStarted = false;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = _syncResolve();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromScryfall());
  }

  @override
  void didUpdateWidget(OverviewCommanderArtBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.playerId != widget.player.playerId ||
        oldWidget.player.commanderImageUrl != widget.player.commanderImageUrl ||
        oldWidget.player.commanderName != widget.player.commanderName ||
        oldWidget.player.selectedDeckId != widget.player.selectedDeckId) {
      _fetchStarted = false;
      _resolvedUrl = _syncResolve();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFromScryfall());
    }
  }

  String? _syncResolve() {
    final p = widget.player;
    final profile = ref.read(profileRepositoryProvider).getProfile();
    final deckRepo = ref.read(deckRepositoryProvider);
    return resolvePlayerCommanderImageUrl(
      commanderName: p.commanderName,
      commanderImageUrl: p.commanderImageUrl,
      selectedDeckId: p.selectedDeckId,
      profile: profile,
      deckRepo: deckRepo,
    );
  }

  Future<void> _fetchFromScryfall() async {
    if (_fetchStarted) return;
    final current = _resolvedUrl?.trim();
    if (current != null && current.isNotEmpty) return;
    final name = widget.player.commanderName?.trim();
    if (name == null || name.isEmpty) return;

    _fetchStarted = true;
    final card = await ref.read(scryfallServiceProvider).fetchCardByName(name);
    final url = card?.imageUrl?.trim();
    if (!mounted || url == null || url.isEmpty) return;

    setState(() => _resolvedUrl = url);
    ref.read(gameProvider.notifier).patchCommanderArt(
      widget.player.playerId,
      commanderImageUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl?.trim();
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: CachedNetworkImage(
            key: ValueKey(url),
            imageUrl: url,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
