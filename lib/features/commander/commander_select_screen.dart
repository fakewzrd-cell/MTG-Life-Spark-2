import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/tokens/motion_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/game_format.dart';
import '../../core/game/lobby_state.dart';
import '../../core/game/scryfall_service.dart';
import '../../core/models/player_deck.dart';
import '../../core/persistence/providers.dart';
import '../../shared/mana/mana_symbol_assets.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

String? _hiveManaCost(String? raw) {
  final n = normalizeScryfallManaCost(raw);
  return n.isEmpty ? null : n;
}

class CommanderSelectScreen extends ConsumerStatefulWidget {
  final String playerId;

  /// When set with [newDeckDisplayName] or [editDeckId], saves a deck instead of the lobby.
  final String? newDeckDisplayName;
  final String? editDeckId;

  /// `GameFormat.name` when saving a new deck from My Decks.
  final String? deckFormat;

  /// [DeckStyle.id] when saving a new deck from My Decks.
  final String? deckStyleId;

  const CommanderSelectScreen({
    super.key,
    required this.playerId,
    this.newDeckDisplayName,
    this.editDeckId,
    this.deckFormat,
    this.deckStyleId,
  });

  bool get _deckMode =>
      (newDeckDisplayName != null && newDeckDisplayName!.isNotEmpty) ||
      (editDeckId != null && editDeckId!.isNotEmpty);

  @override
  ConsumerState<CommanderSelectScreen> createState() =>
      _CommanderSelectScreenState();
}

class _CommanderSelectScreenState
    extends ConsumerState<CommanderSelectScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<ScryfallCard> _results = [];
  bool _loading = false;
  String? _error;

  // Selected cards
  ScryfallCard? _primary;
  ScryfallCard? _partner;
  bool _pickingPartner = false; // true when user is selecting the 2nd card
  var _seededFromLobby = false;

  /// Dual-commander UI is available for commander-style picks; partner is optional.
  bool get _offersPartnerSlot => _isCommanderPick;

  bool get _isCommanderPick {
    if (!widget._deckMode) return true;
    return _deckGameFormat.isCommanderStyle;
  }

  GameFormat get _deckGameFormat {
    final fromRoute = GameFormatDetails.fromName(widget.deckFormat);
    if (fromRoute != null) return fromRoute;
    if (widget.editDeckId != null) {
      final deck =
          ref.read(deckRepositoryProvider).getById(widget.editDeckId!);
      if (deck != null) return deck.gameFormat;
    }
    return GameFormat.commander;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editDeckId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditDeck());
    }
  }

  void _loadEditDeck() {
    final deck =
        ref.read(deckRepositoryProvider).getById(widget.editDeckId!);
    if (deck == null || !mounted) return;
    setState(() {
      _primary = ScryfallCard(
        name: deck.commanderName,
        imageUrl: deck.commanderImageUrl,
        manaCost: deck.commanderManaCost,
        colorIdentity: deck.hasPartner
            ? const []
            : List<String>.from(deck.commanderColorIdentity),
      );
      if (deck.hasPartner && deck.partnerCommanderName != null) {
        _partner = ScryfallCard(
          name: deck.partnerCommanderName!,
          imageUrl: deck.partnerCommanderImageUrl,
          manaCost: deck.partnerManaCost,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget._deckMode || _seededFromLobby) return;
    final lobbySlots = ref.read(lobbyProvider).players;
    final slot = lobbySlots.where((p) => p.playerId == widget.playerId);
    if (slot.isEmpty) return;
    final s = slot.first;
    _seededFromLobby = true;
    if (s.commanderName == null || s.commanderName!.isEmpty) return;
    _primary = ScryfallCard(
      name: s.commanderName!,
      imageUrl: s.commanderImageUrl,
      colorIdentity: List<String>.from(s.commanderColorIdentity),
    );
    final partnerName = s.partnerCommanderName;
    if (partnerName != null && partnerName.isNotEmpty) {
      _partner = ScryfallCard(
        name: partnerName,
        imageUrl: s.partnerCommanderImageUrl,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(scryfallServiceProvider);
      final results = _isCommanderPick
          ? await service.searchCommanders(query)
          : await service.searchCards(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        if (results.isEmpty) {
          _error = _isCommanderPick
              ? 'No commanders found for "$query"'
              : 'No cards found for "$query"';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _error = 'Unable to search. Check your internet connection and try again.';
      });
    }
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void _onCardTap(ScryfallCard card) {
    if (!_isCommanderPick) {
      setState(() {
        _primary = card;
        _partner = null;
        _pickingPartner = false;
      });
      return;
    }
    if (_pickingPartner) {
      setState(() {
        _partner = card;
        _pickingPartner = false;
      });
    } else {
      setState(() {
        _primary = card;
        _partner = null; // reset partner when primary changes
      });
    }
  }

  bool get _canConfirm => _primary != null;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    final usePartner = _offersPartnerSlot && _partner != null;
    if (widget.newDeckDisplayName != null &&
        widget.newDeckDisplayName!.trim().isNotEmpty) {
      final fmt = _deckGameFormat;
      final ci = ScryfallCard.unionColorIdentity(
        _primary!,
        usePartner ? _partner : null,
      );
      final styleId = widget.deckStyleId?.trim() ?? '';
      final deck = PlayerDeck.create(
        displayName: widget.newDeckDisplayName!.trim(),
        format: fmt,
        deckStyleId: styleId,
        commanderName: _primary!.name,
        commanderImageUrl: _primary!.imageUrl,
        partnerCommanderName: usePartner ? _partner?.name : null,
        partnerCommanderImageUrl: usePartner ? _partner?.imageUrl : null,
        commanderManaCost: _hiveManaCost(_primary!.manaCost),
        partnerManaCost: usePartner ? _hiveManaCost(_partner?.manaCost) : null,
        commanderColorIdentity: ci,
      );
      await ref.read(deckRepositoryProvider).save(deck);
      bumpDeckListRevision(ref);
      if (mounted) context.pop();
      return;
    }
    if (widget.editDeckId != null) {
      final repo = ref.read(deckRepositoryProvider);
      final deck = repo.getById(widget.editDeckId!);
      if (deck == null) {
        if (mounted) context.pop();
        return;
      }
      final ci = ScryfallCard.unionColorIdentity(
        _primary!,
        usePartner ? _partner : null,
      );
      deck.commanderName = _primary!.name;
      deck.commanderImageUrl = _primary!.imageUrl;
      deck.commanderManaCost = _hiveManaCost(_primary!.manaCost);
      deck.partnerCommanderName = usePartner ? _partner?.name : null;
      deck.partnerCommanderImageUrl = usePartner ? _partner?.imageUrl : null;
      deck.partnerManaCost =
          usePartner ? _hiveManaCost(_partner?.manaCost) : null;
      deck.commanderColorIdentity = ci;
      await repo.save(deck);
      bumpDeckListRevision(ref);
      if (mounted) context.pop();
      return;
    }
    ref.read(lobbyProvider.notifier).setCommander(
          playerId: widget.playerId,
          commanderName: _primary!.name,
          commanderImageUrl: _primary!.imageUrl ?? '',
          partnerCommanderName: usePartner ? _partner?.name : null,
          partnerCommanderImageUrl:
              usePartner ? (_partner?.imageUrl ?? '') : null,
          commanderColorIdentity: ScryfallCard.unionColorIdentity(
            _primary!,
            usePartner ? _partner : null,
          ),
        );
    if (mounted) context.pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  String get _title {
    if (widget._deckMode) {
      if (widget.editDeckId != null) {
        return _isCommanderPick ? 'Edit commanders' : 'Edit cover card';
      }
      return _isCommanderPick
          ? 'New deck — pick commander'
          : 'New deck — pick cover card';
    }
    return _pickingPartner ? 'Select Partner' : 'Select Commander';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: UiAppBar(
        title: _pickingPartner ? 'Select Partner' : _title,
        actions: [
          if (_canConfirm)
            TextButton(
              onPressed: _confirm,
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // After primary is chosen, show it + optional partner slot.
          if (_primary != null)
            _SelectionPreview(
              primary: _primary,
              partner: _offersPartnerSlot ? _partner : null,
              showPartnerSlot: _offersPartnerSlot,
              onPickPartner: _offersPartnerSlot
                  ? () => setState(() => _pickingPartner = !_pickingPartner)
                  : null,
              onClearPartner: _offersPartnerSlot && _partner != null
                  ? () => setState(() {
                        _partner = null;
                        _pickingPartner = false;
                      })
                  : null,
              pickingPartner: _pickingPartner,
            ),
          if (widget._deckMode && !_isCommanderPick)
            Padding(
              padding: EdgeInsets.fromLTRB(
                LayoutTokens.gr3,
                LayoutTokens.gr1,
                LayoutTokens.gr3,
                0,
              ),
              child: Text(
                'Pick any card for deck art — not your full deck list.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.sm,
                ),
              ),
            ),

          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(LayoutTokens.gr3, LayoutTokens.gr2, LayoutTokens.gr3, 0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _pickingPartner
                    ? 'Search for partner commander…'
                    : _isCommanderPick
                        ? 'Search for a commander…'
                        : 'Search for a card…',
                prefixIcon:
                    Icon(Icons.search, color: colors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: colors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _error = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          SizedBox(height: LayoutTokens.gr2),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final colors = AppColorTokens.of(context);
    if (_loading) {
      return Center(
          child: CircularProgressIndicator(color: colors.primaryAccent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: Text(_error!,
              style: TextStyle(color: colors.textSecondary),
              textAlign: TextAlign.center),
        ),
      );
    }
    if (_results.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Text(
          _isCommanderPick
              ? 'Type a commander name to search the Scryfall database.'
              : 'Type a card name to search the Scryfall database.',
          style: TextStyle(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(LayoutTokens.gr3, 0, LayoutTokens.gr3, LayoutTokens.gr4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final card = _results[i];
        final isSelected = _pickingPartner
            ? card.name == _partner?.name
            : card.name == _primary?.name;
        return _CommanderCard(
          card: card,
          isSelected: isSelected,
          onTap: () => _onCardTap(card),
        );
      },
    );
  }
}

// ── Selection preview strip ───────────────────────────────────────────────

class _SelectionPreview extends StatelessWidget {
  final ScryfallCard? primary;
  final ScryfallCard? partner;
  final bool showPartnerSlot;
  final VoidCallback? onPickPartner;
  final VoidCallback? onClearPartner;
  final bool pickingPartner;

  const _SelectionPreview({
    required this.primary,
    required this.partner,
    required this.showPartnerSlot,
    this.onPickPartner,
    this.onClearPartner,
    required this.pickingPartner,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        LayoutTokens.gr3,
        LayoutTokens.gr2,
        LayoutTokens.gr3,
        LayoutTokens.gr1,
      ),
      color: colors.backgroundSecondary,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              if (primary != null) _MiniCard(card: primary!, label: 'Commander'),
              if (showPartnerSlot) ...[
                const SizedBox(width: 8),
                if (partner != null)
                  GestureDetector(
                    onTap: onPickPartner,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _MiniCard(card: partner!, label: 'Partner'),
                        if (onClearPartner != null)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Material(
                              color: colors.surface,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onClearPartner,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onPickPartner,
                    child: Container(
                      width: 56,
                      height: 78,
                      decoration: BoxDecoration(
                        color: pickingPartner
                            ? colors.primaryAccent.withValues(alpha: 0.15)
                            : colors.surface,
                        borderRadius: RadiusTokens.radiusControlMd,
                        border: Border.all(
                          color: pickingPartner
                              ? colors.primaryAccent
                              : colors.textSecondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: pickingPartner
                                ? colors.primaryAccent
                                : colors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Partner',
                            style: TextStyle(
                              color: pickingPartner
                                  ? colors.primaryAccent
                                  : colors.textSecondary,
                              fontSize: FontTokens.hudXs,
                            ),
                          ),
                          Text(
                            'optional',
                            style: TextStyle(
                              color: colors.textSecondary.withValues(alpha: 0.75),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
          if (pickingPartner && onPickPartner != null)
            Positioned(
              top: -LayoutTokens.gr1,
              right: -LayoutTokens.gr0,
              child: GameDialogCloseButton(onPressed: onPickPartner!),
            ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final ScryfallCard card;
  final String label;
  const _MiniCard({required this.card, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: RadiusTokens.radiusXs,
          child: card.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: card.imageUrl!,
                  width: 56,
                  height: 78,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(colors),
                )
              : _placeholder(colors),
        ),
        SizedBox(height: LayoutTokens.gr0),
        Text(
          label,
          style:
              TextStyle(
                  color: colors.textSecondary, fontSize: FontTokens.hudXs),
        ),
      ],
    );
  }

  Widget _placeholder(AppColorTokens colors) => Container(
        width: 56,
        height: 78,
        color: colors.surface,
        child: Icon(Icons.style, color: colors.textSecondary),
      );
}

// ── Commander card grid item ──────────────────────────────────────────────

class _CommanderCard extends StatelessWidget {
  final ScryfallCard card;
  final bool isSelected;
  final VoidCallback onTap;

  const _CommanderCard({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionTokens.fast,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: RadiusTokens.radiusSm,
          border: Border.all(
            color: isSelected ? colors.primaryAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primaryAccent.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: card.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: card.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: colors.primaryAccent),
                        ),
                        errorWidget: (_, __, ___) => Image.asset(
                          ScryfallCard.offlineImageAsset,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        ScryfallCard.offlineImageAsset,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (card.isPartner)
                    Text(
                      'Partner',
                      style: TextStyle(
                          color: colors.emphasis, fontSize: FontTokens.hudXs),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
