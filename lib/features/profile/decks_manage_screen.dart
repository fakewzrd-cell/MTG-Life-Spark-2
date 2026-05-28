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
import '../../ui/components/ui_dialog_actions.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
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
    _reload();
  }

  void _reload() {
    setState(() {
      _decks = ref.read(deckRepositoryProvider).getAll();
    });
  }

  Future<void> _promptNewDeckName() async {
    final controller = TextEditingController();
    var selectedFormat = GameFormat.commander;
    final result = await showDialog<({String name, GameFormat format})>(
      context: context,
      builder: (ctx) {
        final colors = AppColorTokens.of(ctx);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: GameDialogTitleRow(
                title: 'New deck',
                onClose: () => Navigator.pop(ctx),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Deck name',
                      hintText: 'e.g. Raffine Tempo',
                      hintStyle: TextStyle(color: colors.textSecondary),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  SizedBox(height: LayoutTokens.gr3),
                  DropdownButtonFormField<GameFormat>(
                    initialValue: selectedFormat,
                    decoration: InputDecoration(
                      labelText: 'Format',
                      labelStyle: TextStyle(color: colors.textSecondary),
                    ),
                    dropdownColor: colors.surface,
                    style: TextStyle(color: colors.textPrimary),
                    items: GameFormatDetails.lobbyPickerOrder
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (f) {
                      if (f == null) return;
                      setDialogState(() => selectedFormat = f);
                    },
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    final t = controller.text.trim();
                    if (t.isEmpty) return;
                    Navigator.pop(ctx, (name: t, format: selectedFormat));
                  },
                  child: const Text('Next'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null || !mounted) return;
    final profile = ref.read(profileRepositoryProvider).getProfile();
    if (profile == null) return;
    await context.push(
      AppRoutes.commanderSelect,
      extra: {
        'playerId': profile.username,
        'newDeckDisplayName': result.name,
        'deckFormat': result.format.name,
      },
    );
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _editCommanders(PlayerDeck deck) async {
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
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _renameDeck(DeckRepository repo, PlayerDeck deck) async {
    final controller = TextEditingController(text: deck.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final colors = AppColorTokens.of(ctx);
        return AlertDialog(
          title: GameDialogTitleRow(
            title: 'Rename deck',
            onClose: () => Navigator.pop(ctx),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                final t = controller.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(ctx, t);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (name == null || name == deck.displayName) return;
    deck.displayName = name;
    await repo.save(deck);
    bumpDeckListRevision(ref);
    _reload();
  }

  Future<void> _confirmDelete(DeckRepository repo, PlayerDeck deck) async {
    final colors = AppColorTokens.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: GameDialogTitleRow(
          title: 'Delete deck?',
          onClose: () => Navigator.pop(ctx, false),
        ),
        content: Text(
          'Remove “${deck.displayName}” from your library? Match history stays, '
          'but this deck will no longer appear in the lobby picker.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: UiDialogActions.cancelConfirm(
          context: ctx,
          confirmLabel: 'Delete',
          onConfirm: () => Navigator.pop(ctx, true),
          isDestructive: true,
        ),
      ),
    );
    if (ok == true) {
      await repo.delete(deck.id);
      bumpDeckListRevision(ref);
      _reload();
    }
  }

  void _showDeckOptionsSheet(PlayerDeck deck, DeckRepository repo) {
    final colors = AppColorTokens.of(context);
    final coverLabel = deck.isCommanderDeck ? 'Edit commanders' : 'Edit cover card';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  LayoutTokens.gr3,
                  LayoutTokens.gr1,
                  LayoutTokens.gr3,
                  LayoutTokens.gr2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.displayName,
                      style: TypographyTokens.cardTitle(colors.textPrimary),
                    ),
                    Text(
                      deck.gameFormat.displayName,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontTokens.sm,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.style_outlined, color: colors.primaryAccent),
                title: Text(coverLabel),
                onTap: () {
                  Navigator.pop(ctx);
                  _editCommanders(deck);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: colors.textPrimary),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(ctx);
                  _renameDeck(repo, deck);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.error),
                title: Text(
                  'Delete deck',
                  style: TextStyle(color: colors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(repo, deck);
                },
              ),
              SizedBox(height: LayoutTokens.gr2),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deckListRevisionProvider, (_, __) => _reload());
    final colors = AppColorTokens.of(context);
    final repo = ref.read(deckRepositoryProvider);
    final bottomBarPad = LayoutTokens.shellBottomInset(context);
    final grouped = _groupDecksByFormat(_decks);
    final cardHeight = profileBentoCardHeight(context);

    final isEmpty = _decks.isEmpty;

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
          onDeckTap: (deck) => _showDeckOptionsSheet(deck, repo),
        ),
      );
      sectionChildren.add(SizedBox(height: LayoutTokens.gr4));
    }

    Widget scrollBody;
    if (isEmpty) {
      scrollBody = Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr4),
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
            ],
          ),
        ),
      );
    } else {
      scrollBody = ListView(
        padding: EdgeInsets.fromLTRB(
          LayoutTokens.gr3,
          LayoutTokens.gr3,
          LayoutTokens.gr3,
          LayoutTokens.gr2,
        ),
        children: sectionChildren,
      );
    }

    return Scaffold(
      appBar: const UiAppBar(title: 'My decks'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: scrollBody),
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutTokens.gr3,
              LayoutTokens.gr2,
              LayoutTokens.gr3,
              bottomBarPad,
            ),
            child: UiButton(
              label: 'Add deck',
              icon: const Icon(Icons.add_rounded, size: 22),
              onPressed: _promptNewDeckName,
            ),
          ),
        ],
      ),
    );
  }
}

/// One format section: title + horizontal row of profile-style deck bento cards.
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
                    borderRadius: RadiusTokens.radiusBento,
                    child: ProfileDeckBentoTile(
                      deck: deck,
                      colors: colors,
                      width: kProfileBentoCardWidth,
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
