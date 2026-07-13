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
    list.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
  }
  return grouped;
}

class _DecksManageScreenState extends ConsumerState<DecksManageScreen> {
  List<PlayerDeck> _decks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
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

  Future<void> _confirmDelete(DeckRepository repo, PlayerDeck deck) async {
    final ok = await showDeleteDeckConfirm(context, deck);
    if (!ok || !mounted) return;
    await repo.delete(deck.id);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _onDeckTap(PlayerDeck deck, DeckRepository repo) async {
    final action = await showDeckOptionsSheet(context, deck);
    if (action == null || !mounted) return;

    switch (action) {
      case DeckSheetAction.changeStyle:
        await _changeDeckStyle(repo, deck);
      case DeckSheetAction.editCover:
        await _editCommanders(deck, repo);
      case DeckSheetAction.rename:
        await _renameDeck(repo, deck);
      case DeckSheetAction.delete:
        await _confirmDelete(repo, deck);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deckListRevisionProvider, (_, __) => _reload());
    final colors = AppColorTokens.of(context);
    final repo = ref.read(deckRepositoryProvider);
    final bottomBarPad = LayoutTokens.shellBottomInset(context);
    final grouped = _groupDecksByFormat(_decks);
    final cardHeight = profileCarouselCardHeight(context);

    final isEmpty = _decks.isEmpty;
    const fabSize = 40.0;
    final fabBottom = MediaQuery.paddingOf(context).bottom + LayoutTokens.gr1;
    final fabStackClearance = fabBottom + fabSize + LayoutTokens.gr2;

    final sectionChildren = <Widget>[];
    for (final format in GameFormatDetails.lobbyPickerOrder) {
      final decks = grouped[format];
      if (decks == null || decks.isEmpty) continue;
      sectionChildren.add(
        _DecksFormatRow(
          format: format,
          decks: decks,
          cardHeight: cardHeight,
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
          top: LayoutTokens.gr4,
        ).copyWith(
          bottom: fabStackClearance,
        ),
        children: sectionChildren,
      );
    }

    final addFab = FloatingActionButton.small(
      onPressed: _promptNewDeckName,
      tooltip: 'Add deck',
      child: const Icon(Icons.add_rounded),
    );

    return Scaffold(
      appBar: const UiAppBar(title: 'Decks'),
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: scrollBody),
          if (!isEmpty)
            Positioned(
              right: LayoutTokens.shellPageInset,
              bottom: fabBottom,
              child: addFab,
            ),
        ],
      ),
    );
  }
}

/// One format section: title + horizontal row of profile-style deck cards.
class _DecksFormatRow extends StatelessWidget {
  const _DecksFormatRow({
    required this.format,
    required this.decks,
    required this.cardHeight,
    required this.colors,
    required this.onDeckTap,
  });

  final GameFormat format;
  final List<PlayerDeck> decks;
  final double cardHeight;
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
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            primary: false,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: kProfileHorizontalCarouselPhysics,
            padding: EdgeInsets.only(right: LayoutTokens.gr1),
            itemCount: decks.length,
            separatorBuilder: (_, __) => SizedBox(width: LayoutTokens.gr2),
            itemBuilder: (context, i) {
              final deck = decks[i];
              return Semantics(
                button: true,
                label: '${deck.displayName}, ${format.displayName}',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDeckTap(deck),
                    borderRadius: RadiusTokens.radiusCarouselCard,
                    child: ProfileDeckCard(
                      deck: deck,
                      colors: colors,
                      width: kProfileCarouselCardWidth,
                      height: cardHeight,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
