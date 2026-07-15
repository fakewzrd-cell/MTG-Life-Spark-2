import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/game_format.dart';
import '../../core/models/player_deck.dart';
import '../../core/persistence/deck_repository.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import 'deck_options_sheet.dart';
import 'deck_style_picker_sheet.dart';
import 'game_format_picker_sheet.dart';
import 'new_deck_sheet.dart';
import 'profile_carousel_sections.dart';

class DecksManageScreen extends ConsumerStatefulWidget {
  const DecksManageScreen({super.key});

  @override
  ConsumerState<DecksManageScreen> createState() => _DecksManageScreenState();
}

Map<GameFormat, List<PlayerDeck>> _groupDecksByFormat(List<PlayerDeck> decks) {
  final grouped = <GameFormat, List<PlayerDeck>>{};
  for (final deck in decks) {
    grouped.putIfAbsent(deck.gameFormat, () => []).add(deck);
  }
  for (final list in grouped.values) {
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
  }
  return grouped;
}

bool _deckMatchesQuery(PlayerDeck deck, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  return deck.displayName.toLowerCase().contains(q) ||
      deck.commanderName.toLowerCase().contains(q) ||
      (deck.partnerCommanderName?.toLowerCase().contains(q) ?? false) ||
      deck.deckStyleDisplayName.toLowerCase().contains(q) ||
      deck.gameFormat.displayName.toLowerCase().contains(q);
}

class _DecksManageScreenState extends ConsumerState<DecksManageScreen> {
  List<PlayerDeck> _decks = [];
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _decks = ref.read(deckRepositoryProvider).getAll();
    });
  }

  Future<void> _promptNewDeckName() async {
    final result = await showNewDeckSheet(context);
    if (result == null || !mounted) return;
    final profile = ref.read(profileRepositoryProvider).getProfile();
    if (profile == null) return;
    await context.push(
      AppRoutes.commanderSelect,
      extra: {
        'playerId': profile.username,
        'newDeckDisplayName': result.name,
        'deckFormat': result.format.name,
        'deckStyleId': result.deckStyleId,
      },
    );
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<bool> _ensureDeckStyle(PlayerDeck deck, DeckRepository repo) async {
    if (deck.hasDeckStyle) return true;
    final picked = await showDeckStylePickerSheet(context);
    if (picked == null || !mounted) return false;
    deck.deckStyleId = picked.id;
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
    return true;
  }

  Future<void> _changeDeckStyle(DeckRepository repo, PlayerDeck deck) async {
    final picked = await showDeckStylePickerSheet(
      context,
      selected: deck.deckStyle,
    );
    if (picked == null || picked.id == deck.deckStyleId) return;
    deck.deckStyleId = picked.id;
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _changeFormat(DeckRepository repo, PlayerDeck deck) async {
    final picked = await showGameFormatPickerSheet(
      context,
      selected: deck.gameFormat,
    );
    if (picked == null || picked == deck.gameFormat || !mounted) return;
    final wasCommander = deck.isCommanderDeck;
    deck.format = picked.name;
    if (wasCommander && !picked.isCommanderStyle) {
      deck.partnerCommanderName = null;
      deck.partnerCommanderImageUrl = null;
      deck.partnerManaCost = null;
    }
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _editCommanders(PlayerDeck deck, DeckRepository repo) async {
    if (!await _ensureDeckStyle(deck, repo)) return;
    if (!mounted) return;
    final profile = ref.read(profileRepositoryProvider).getProfile();
    if (profile == null) return;
    await context.push(
      AppRoutes.commanderSelect,
      extra: {
        'playerId': profile.username,
        'editDeckId': deck.id,
        'deckFormat': deck.format,
      },
    );
    if (!mounted) return;
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _renameDeck(DeckRepository repo, PlayerDeck deck) async {
    final name = await showRenameDeckDialog(
      context,
      initialName: deck.displayName,
    );
    if (name == null || name == deck.displayName || !mounted) return;
    deck.displayName = name;
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _togglePin(DeckRepository repo, PlayerDeck deck) async {
    deck.isPinned = !deck.isPinned;
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _duplicateDeck(DeckRepository repo, PlayerDeck deck) async {
    await repo.duplicate(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _confirmDelete(DeckRepository repo, PlayerDeck deck) async {
    final ok = await showDeleteDeckConfirm(context, deck);
    if (!ok || !mounted) return;
    await repo.delete(deck.id);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _onDeckTap(PlayerDeck deck, DeckRepository repo) async {
    final action = await showDeckDetailSheet(context, deck);
    if (action == null || !mounted) return;

    switch (action) {
      case DeckSheetAction.togglePin:
        await _togglePin(repo, deck);
      case DeckSheetAction.changeFormat:
        await _changeFormat(repo, deck);
      case DeckSheetAction.changeStyle:
        await _changeDeckStyle(repo, deck);
      case DeckSheetAction.editCover:
        await _editCommanders(deck, repo);
      case DeckSheetAction.rename:
        await _renameDeck(repo, deck);
      case DeckSheetAction.duplicate:
        await _duplicateDeck(repo, deck);
      case DeckSheetAction.delete:
        await _confirmDelete(repo, deck);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deckListRevisionProvider, (_, _) => _reload());
    final colors = AppColorTokens.of(context);
    final repo = ref.read(deckRepositoryProvider);
    final bottomBarPad = LayoutTokens.shellBottomInset(context);

    final filtered =
        _decks.where((d) => _deckMatchesQuery(d, _query)).toList();
    final grouped = _groupDecksByFormat(filtered);

    final isEmpty = _decks.isEmpty;
    final noMatches = !isEmpty && filtered.isEmpty;

    final sectionChildren = <Widget>[];
    for (final format in GameFormatDetails.lobbyPickerOrder) {
      final decks = grouped[format];
      if (decks == null || decks.isEmpty) continue;
      sectionChildren.add(
        _DecksFormatSection(
          format: format,
          decks: decks,
          colors: colors,
          onDeckTap: (deck) => _onDeckTap(deck, repo),
        ),
      );
      sectionChildren.add(SizedBox(height: LayoutTokens.shellSectionGap));
    }

    Widget scrollBody;
    if (isEmpty) {
      scrollBody = Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            LayoutTokens.shellPageInset,
            LayoutTokens.shellPageInset,
            LayoutTokens.shellPageInset,
            bottomBarPad,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.style_outlined,
                size: 56,
                color: colors.primaryAccent.withValues(alpha: 0.85),
              ),
              SizedBox(height: LayoutTokens.gr4),
              Text(
                'Build your deck library',
                textAlign: TextAlign.center,
                style: TypographyTokens.sectionTitle(colors.textPrimary),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Text(
                'Save a deck with a name, format, and cover card. '
                'When you host or join a game, pick the right list in the lobby.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontSize: FontTokens.body,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: LayoutTokens.gr5),
              UiButton(
                label: 'Add deck',
                icon: const Icon(Icons.add_rounded, size: 22),
                onPressed: _promptNewDeckName,
              ),
            ],
          ),
        ),
      );
    } else {
      scrollBody = ListView(
        padding: LayoutTokens.shellListPadding(
          context,
          top: LayoutTokens.gr2,
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: LayoutTokens.gr3),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search decks…',
                prefixIcon: const Icon(Icons.search_rounded),
                hintStyle: TextStyle(color: colors.textSecondary),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
          if (noMatches)
            Padding(
              padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr6),
              child: Text(
                'No decks match “$_query”.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            ...sectionChildren,
        ],
      );
    }

    return Scaffold(
      appBar: UiAppBar(
        title: 'Decks',
        actions: [
          if (!isEmpty)
            TextButton.icon(
              onPressed: _promptNewDeckName,
              icon: Icon(
                Icons.add_rounded,
                size: 20,
                color: colors.primaryAccent,
              ),
              label: Text(
                'Add',
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: colors.backgroundPrimary,
      body: scrollBody,
    );
  }
}

/// Format section: header + vertical list of compact deck rows.
class _DecksFormatSection extends StatelessWidget {
  const _DecksFormatSection({
    required this.format,
    required this.decks,
    required this.colors,
    required this.onDeckTap,
  });

  final GameFormat format;
  final List<PlayerDeck> decks;
  final AppColorTokens colors;
  final ValueChanged<PlayerDeck> onDeckTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TypographyTokens.sectionTitle(colors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionHeader(
          title: format.displayName,
          titleStyle: titleStyle,
          colors: colors,
          count: decks.length,
          singularUnit: 'deck',
          pluralUnit: 'decks',
        ),
        SizedBox(height: LayoutTokens.gr2),
        ...[
          for (var i = 0; i < decks.length; i++) ...[
            if (i > 0) SizedBox(height: LayoutTokens.gr2),
            _DeckLibraryTile(
              deck: decks[i],
              colors: colors,
              onTap: () => onDeckTap(decks[i]),
            ),
          ],
        ],
      ],
    );
  }
}

/// Compact scannable row for the decks library (not a carousel card).
class _DeckLibraryTile extends StatelessWidget {
  const _DeckLibraryTile({
    required this.deck,
    required this.colors,
    required this.onTap,
  });

  final PlayerDeck deck;
  final AppColorTokens colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final commanderLine = deck.isCommanderDeck && deck.hasPartner
        ? '${deck.commanderName} // ${deck.partnerCommanderName}'
        : deck.commanderName;
    final styleLine = deck.hasDeckStyle
        ? deck.deckStyleDisplayName
        : 'Style not set';
    final wr = deck.gamesPlayed == 0
        ? null
        : (deck.winRate * 100).round();

    return Semantics(
      button: true,
      label: '${deck.displayName}, ${deck.gameFormat.displayName}',
      child: Material(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusMd,
          child: Padding(
            padding: EdgeInsets.all(LayoutTokens.gr2),
            child: Row(
              children: [
                _DeckCoverThumb(deck: deck, colors: colors),
                SizedBox(width: LayoutTokens.gr3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (deck.isPinned) ...[
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: colors.primaryAccent,
                            ),
                            SizedBox(width: LayoutTokens.gr0),
                          ],
                          Expanded(
                            child: Text(
                              deck.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: FontTokens.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: LayoutTokens.gr0),
                      Text(
                        commanderLine.isEmpty ? 'No cover card' : commanderLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.sm,
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr0),
                      Text(
                        styleLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: deck.hasDeckStyle
                              ? colors.textSecondary
                              : colors.warning,
                          fontSize: FontTokens.sm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: LayoutTokens.gr2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      wr == null ? '—' : '$wr%',
                      style: TextStyle(
                        color: colors.primaryAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: FontTokens.body,
                      ),
                    ),
                    Text(
                      '${deck.wins}W–${deck.losses}L',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontTokens.xs,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckCoverThumb extends StatelessWidget {
  const _DeckCoverThumb({
    required this.deck,
    required this.colors,
  });

  final PlayerDeck deck;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final url = deck.commanderImageUrl;
    return ClipRRect(
      borderRadius: RadiusTokens.radiusSm,
      child: SizedBox(
        width: 48,
        height: 68,
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => ColoredBox(
                  color: colors.backgroundPrimary,
                  child: Icon(
                    Icons.style_outlined,
                    color: colors.textSecondary,
                  ),
                ),
              )
            : ColoredBox(
                color: colors.backgroundPrimary,
                child: Icon(
                  Icons.style_outlined,
                  color: colors.textSecondary,
                ),
              ),
      ),
    );
  }
}
