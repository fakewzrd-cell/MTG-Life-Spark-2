import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/game_state_notifier.dart';
import '../../../core/game/stack_display.dart';
import '../../../core/game/scryfall_service.dart';
import '../../../core/game/stack_item.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/mana_cost_pips.dart';
import '../../../ui/tokens/layout_tokens.dart';
import 'stack_card_picker_dialog.dart';
import 'stack_help_sheet.dart';

/// Stack tracker: beginner-friendly LIFO list with optional by-player view.
class StackTrackerTab extends ConsumerStatefulWidget {
  final GameState game;

  const StackTrackerTab({super.key, required this.game});

  @override
  ConsumerState<StackTrackerTab> createState() => _StackTrackerTabState();
}

class _StackTrackerTabState extends ConsumerState<StackTrackerTab> {
  StackSortMode _sortMode = StackSortMode.stackOrder;
  bool _showCountered = false;
  bool _tipBannerVisible = true;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final notifier = ref.read(gameProvider.notifier);
    final allItems = game.stackItems;
    final visible = _showCountered
        ? allItems
        : allItems.where((i) => i.showsOnStack).toList();
    final resolvesNext = StackDisplay.resolvesNextItem(allItems);
    final activeRoots = StackDisplay.activeRootsNewestFirst(allItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            LayoutTokens.gr3,
            LayoutTokens.gr2,
            LayoutTokens.gr3,
            LayoutTokens.gr1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _sortMode == StackSortMode.stackOrder
                      ? 'Order on stack'
                      : 'By player',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Add spell or ability',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppTheme.accent,
                ),
                onPressed: () => _showAddDialog(context, parentId: null),
              ),
              IconButton(
                tooltip: 'How the stack works',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: AppTheme.textSecondary.withValues(alpha: 0.9),
                ),
                onPressed: () => StackHelpSheet.show(context),
              ),
              FilterChip(
                label: const Text('By player'),
                selected: _sortMode == StackSortMode.apnap,
                onSelected: (v) => setState(
                  () => _sortMode =
                      v ? StackSortMode.apnap : StackSortMode.stackOrder,
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(width: LayoutTokens.gr1),
              FilterChip(
                label: const Text('Countered'),
                selected: _showCountered,
                onSelected: (v) => setState(() => _showCountered = v),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        if (_sortMode == StackSortMode.apnap)
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutTokens.gr3,
              0,
              LayoutTokens.gr3,
              LayoutTokens.gr1,
            ),
            child: Text(
              'Who added what (active player first)',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ),
        if (_tipBannerVisible)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
            child: _TipBanner(
              onHide: () => setState(() => _tipBannerVisible = false),
            ),
          ),
        if (game.stackItems.isNotEmpty &&
            (game.isHost || game.players.length <= 1))
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: LayoutTokens.gr1,
                runSpacing: LayoutTokens.gr0,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _confirmClearAll(context, notifier),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Clear all'),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: visible.isEmpty
              ? _EmptyStackState(
                  onPutOnStack: () => _showAddDialog(context, parentId: null),
                  onLoadExample: game.isHost || game.players.length <= 1
                      ? () => notifier.loadExampleStack()
                      : null,
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    LayoutTokens.gr3,
                    LayoutTokens.gr1,
                    LayoutTokens.gr3,
                    LayoutTokens.gr6,
                  ),
                  children: _sortMode == StackSortMode.stackOrder
                      ? _stackOrderChildren(
                          game,
                          visible,
                          resolvesNext,
                          activeRoots,
                        )
                      : _apnapChildren(game, visible, resolvesNext),
                ),
        ),
      ],
    );
  }

  List<Widget> _stackOrderChildren(
    GameState game,
    List<StackItem> visible,
    StackItem? resolvesNext,
    List<StackItem> activeRoots,
  ) {
    final tree = StackDisplay.stackOrderTree(
      visible,
      includeInactive: _showCountered,
    );
    return [
      for (final node in tree)
        _StackNodeTile(
          game: game,
          node: node,
          resolvesNextId: resolvesNext?.id,
          activeRoots: activeRoots,
          allItems: game.stackItems,
        ),
    ];
  }

  List<Widget> _apnapChildren(
    GameState game,
    List<StackItem> visible,
    StackItem? resolvesNext,
  ) {
    final filteredGame = game.copyWith(stackItems: visible);
    final groups = StackDisplay.apnapGroups(filteredGame);
    return [
      for (final g in groups) ...[
        Padding(
          padding: EdgeInsets.only(
            top: LayoutTokens.gr2,
            bottom: LayoutTokens.gr1,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: game.playerById(g.playerId)?.playerColor ??
                      AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: LayoutTokens.gr2),
              Text(
                g.isActivePlayer
                    ? '${g.username} · Active player'
                    : '${g.username} · Turn order: ${g.turnOrderPosition}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: g.isActivePlayer
                      ? AppTheme.accent
                      : AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        for (final item in g.items)
          _StackItemTile(
            game: game,
            item: item,
            depth: 0,
            resolvesNextId: resolvesNext?.id,
            showWaitsHint: false,
            nestedResponses: _nestedUnder(item, visible),
            allItems: game.stackItems,
          ),
      ],
    ];
  }

  List<StackItem> _nestedUnder(StackItem parent, List<StackItem> visible) {
    return visible
        .where((i) => i.parentId == parent.id)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    GameStateNotifier notifier,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear stack?'),
        content: const Text(
          'Remove every spell and ability on the stack. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (ok == true) notifier.clearAllStackItems();
  }

  Future<void> _showAddDialog(
    BuildContext context, {
    required String? parentId,
  }) async {
    await openStackAddDialog(context, ref, parentId: parentId);
  }
}

Future<void> openStackAddDialog(
  BuildContext context,
  WidgetRef ref, {
  required String? parentId,
}) async {
  final card = await showStackCardPickerDialog(
    context,
    title: parentId == null ? 'Put on stack' : 'In response to…',
  );
  if (card == null || !context.mounted) return;
  scheduleStackAddItem(ref, context, card: card, parentId: parentId);
}

void scheduleStackAddItem(
  WidgetRef ref,
  BuildContext context, {
  required ScryfallCard card,
  required String? parentId,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    ref.read(gameProvider.notifier).addStackItem(
          name: card.name,
          parentId: parentId,
          oracleText: card.oracleText,
          manaCost: card.manaCost,
          imageUrl: card.imageUrl,
          typeLine: card.typeLine,
        );
  });
}

class _TipBanner extends StatelessWidget {
  final VoidCallback onHide;

  const _TipBanner({required this.onHide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(LayoutTokens.gr2),
        ),
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top spell resolves first. Add newest on top. Search Scryfall when adding cards so names and rules are correct.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.textPrimary.withValues(alpha: 0.9),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onHide,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Hide tip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStackState extends StatelessWidget {
  final VoidCallback onPutOnStack;
  final VoidCallback? onLoadExample;

  const _EmptyStackState({
    required this.onPutOnStack,
    this.onLoadExample,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutTokens.gr4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: LayoutTokens.gr3),
            Text(
              'Nothing on the stack',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: LayoutTokens.gr2),
            _emptyBullet('Put spells and abilities here before they resolve.'),
            _emptyBullet('The last one added resolves first.'),
            _emptyBullet('Load the 4-player example to preview a full pod stack.'),
            SizedBox(height: LayoutTokens.gr4),
            FilledButton.icon(
              onPressed: onPutOnStack,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add spell'),
            ),
            if (onLoadExample != null) ...[
              SizedBox(height: LayoutTokens.gr2),
              OutlinedButton.icon(
                onPressed: onLoadExample,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Load 4-player example'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackNodeTile extends ConsumerWidget {
  final GameState game;
  final StackDisplayNode node;
  final String? resolvesNextId;
  final List<StackItem> activeRoots;
  final List<StackItem> allItems;

  const _StackNodeTile({
    required this.game,
    required this.node,
    required this.resolvesNextId,
    required this.activeRoots,
    required this.allItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRoot = node.depth == 0;
    final showWaits = isRoot &&
        node.item.isActive &&
        resolvesNextId != null &&
        node.item.id != resolvesNextId &&
        activeRoots.any((r) => r.id == node.item.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StackItemTile(
          game: game,
          item: node.item,
          depth: node.depth,
          resolvesNextId: resolvesNextId,
          showWaitsHint: showWaits,
          nestedResponses: const [],
          allItems: allItems,
        ),
        for (final child in node.responses)
          _StackNodeTile(
            game: game,
            node: child,
            resolvesNextId: resolvesNextId,
            activeRoots: activeRoots,
            allItems: allItems,
          ),
      ],
    );
  }
}

class _StackItemTile extends ConsumerWidget {
  final GameState game;
  final StackItem item;
  final int depth;
  final String? resolvesNextId;
  final bool showWaitsHint;
  final List<StackItem> nestedResponses;
  final List<StackItem> allItems;

  const _StackItemTile({
    required this.game,
    required this.item,
    required this.depth,
    required this.resolvesNextId,
    required this.showWaitsHint,
    required this.nestedResponses,
    required this.allItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final owner = game.playerById(item.playerId);
    final canEdit = notifier.canEditStackItem(item);
    final canStatus = notifier.canChangeStackItemStatus(item);
    final isLocal = item.playerId == game.localPlayerId;
    final isFizzled = item.status == StackItemStatus.fizzled;
    final isResolved = item.status == StackItemStatus.resolved;
    final isResolvesNext =
        item.isActive && item.id == resolvesNextId;
    final parentName = StackDisplay.parentNameFor(item, allItems);

    final targetInvalid =
        StackDisplay.hasInvalidStackTarget(item, allItems);
    final showFizzleToggle = canStatus &&
        (isFizzled ||
            (item.isActive &&
                (targetInvalid || item.parentId != null)));
    final statusLabel = switch (item.status) {
      StackItemStatus.resolved => 'Resolved',
      StackItemStatus.countered => 'Countered',
      StackItemStatus.fizzled => 'Fizzled',
      StackItemStatus.active => null,
    };
    final statusColor = switch (item.status) {
      StackItemStatus.resolved => AppTheme.success,
      StackItemStatus.countered => AppTheme.danger,
      StackItemStatus.fizzled => AppTheme.dangerAmber,
      StackItemStatus.active => null,
    };

    final borderColor = isResolvesNext
        ? AppTheme.accent
        : AppTheme.textSecondary.withValues(alpha: 0.14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: depth * LayoutTokens.gr4,
            bottom: LayoutTokens.gr1,
          ),
          child: Material(
            color: isFizzled
                ? AppTheme.card.withValues(alpha: 0.72)
                : isResolved
                    ? AppTheme.success.withValues(alpha: 0.14)
                    : AppTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LayoutTokens.gr2),
              side: BorderSide(
                color: isFizzled
                    ? AppTheme.dangerAmber.withValues(alpha: 0.35)
                    : isResolved
                        ? AppTheme.success.withValues(alpha: 0.55)
                        : borderColor,
                width: isResolvesNext ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(LayoutTokens.gr2),
              onTap: item.isActive || isFizzled || isResolved
                  ? () => _openItemMenu(context, ref, item)
                  : null,
              onLongPress: canEdit
                  ? () => _renameItem(context, ref, item)
                  : null,
              child: Opacity(
                opacity: isFizzled ? 0.62 : isResolved ? 0.92 : 1,
                child: Padding(
                padding: EdgeInsets.all(LayoutTokens.gr2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isResolvesNext)
                      Padding(
                        padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: LayoutTokens.gr2,
                                vertical: LayoutTokens.gr1 / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.25),
                                borderRadius:
                                    BorderRadius.circular(LayoutTokens.gr1),
                              ),
                              child: Text(
                                'Resolves next',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ),
                            SizedBox(width: LayoutTokens.gr1),
                            Text(
                              '#1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                owner?.playerColor ?? AppTheme.textSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: LayoutTokens.gr2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                        decoration: (isFizzled || isResolved)
                                            ? null
                                            : (item.isActive
                                                ? null
                                                : TextDecoration
                                                    .lineThrough),
                                      ),
                                    ),
                                  ),
                                  if (item.manaCost != null &&
                                      item.manaCost!.isNotEmpty) ...[
                                    SizedBox(width: LayoutTokens.gr1),
                                    ManaCostPips(
                                      manaCost: item.manaCost,
                                      symbolHeight: 14,
                                    ),
                                  ],
                                  if (item.oracleText != null &&
                                      item.oracleText!.trim().isNotEmpty)
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      tooltip: 'Card rules',
                                      icon: Icon(
                                        Icons.menu_book_outlined,
                                        size: 20,
                                        color: AppTheme.textSecondary
                                            .withValues(alpha: 0.9),
                                      ),
                                      onPressed: () =>
                                          _showOracleText(context, item),
                                    ),
                                ],
                              ),
                              if (item.typeLabel != null) ...[
                                SizedBox(height: LayoutTokens.gr1 / 2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: LayoutTokens.gr1,
                                    vertical: LayoutTokens.gr1 / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(LayoutTokens.gr1),
                                  ),
                                  child: Text(
                                    item.typeLabel!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary
                                          .withValues(alpha: 0.95),
                                    ),
                                  ),
                                ),
                              ],
                              if (parentName != null) ...[
                                SizedBox(height: LayoutTokens.gr1 / 2),
                                Text(
                                  'In response to $parentName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                              SizedBox(height: LayoutTokens.gr1 / 2),
                              Text(
                                '${owner?.username ?? item.playerId}${isLocal ? ' (you)' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                              if (showWaitsHint)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: LayoutTokens.gr1 / 2,
                                  ),
                                  child: Text(
                                    'Resolves after items above',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary
                                          .withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              if (targetInvalid && item.isActive) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: LayoutTokens.gr1 / 2,
                                  ),
                                  child: Text(
                                    'Target is no longer on the stack',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.dangerAmber,
                                    ),
                                  ),
                                ),
                              ],
                              if (statusLabel != null && statusColor != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: LayoutTokens.gr1 / 2,
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (showFizzleToggle || (item.isActive && canStatus))
                          isResolvesNext
                              ? _StackItemActions(
                                  notifier: notifier,
                                  itemId: item.id,
                                  isFizzled: isFizzled,
                                  labeled: true,
                                  showResolveRespond:
                                      item.isActive && canStatus,
                                  showFizzleToggle: showFizzleToggle,
                                  onRespond: () => openStackAddDialog(
                                    context,
                                    ref,
                                    parentId: item.id,
                                  ),
                                )
                              : _StackItemActions(
                                  notifier: notifier,
                                  itemId: item.id,
                                  isFizzled: isFizzled,
                                  labeled: false,
                                  showResolveRespond:
                                      item.isActive && canStatus,
                                  showFizzleToggle: showFizzleToggle,
                                  onRespond: () => openStackAddDialog(
                                    context,
                                    ref,
                                    parentId: item.id,
                                  ),
                                ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
        for (final child in nestedResponses)
          _StackItemTile(
            game: game,
            item: child,
            depth: depth + 1,
            resolvesNextId: resolvesNextId,
            showWaitsHint: false,
            nestedResponses: allItems
                .where((i) => i.parentId == child.id)
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
            allItems: allItems,
          ),
      ],
    );
  }

  Future<void> _openItemMenu(
    BuildContext context,
    WidgetRef ref,
    StackItem item,
  ) async {
    final notifier = ref.read(gameProvider.notifier);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isActive)
              ListTile(
                leading: const Icon(Icons.reply_rounded),
                title: const Text('In response to…'),
                onTap: () => Navigator.pop(ctx, 'respond'),
              ),
            if (notifier.canChangeStackItemStatus(item) &&
                (item.isActive || item.status == StackItemStatus.fizzled))
              ListTile(
                leading: Icon(
                  Icons.not_interested_rounded,
                  color: AppTheme.dangerAmber,
                ),
                title: Text(
                  item.status == StackItemStatus.fizzled
                      ? 'Undo fizzle'
                      : 'Fizzle',
                ),
                subtitle: Text(
                  item.status == StackItemStatus.fizzled
                      ? 'Put this spell back on the stack as active'
                      : 'Target illegal or spell left the stack (rules counter)',
                ),
                onTap: () => Navigator.pop(ctx, 'toggle_fizzle'),
              ),
            if (item.isActive && notifier.canChangeStackItemStatus(item))
              ListTile(
                leading: const Icon(Icons.block_rounded),
                title: const Text('Mark countered'),
                onTap: () => Navigator.pop(ctx, 'countered'),
              ),
            if (notifier.canEditStackItem(item))
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Rename'),
                onTap: () => Navigator.pop(ctx, 'rename'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'respond') {
      await openStackAddDialog(context, ref, parentId: item.id);
    } else if (action == 'toggle_fizzle') {
      notifier.setStackItemStatus(
        item.id,
        item.status == StackItemStatus.fizzled
            ? StackItemStatus.active
            : StackItemStatus.fizzled,
      );
    } else if (action == 'countered') {
      notifier.setStackItemStatus(item.id, StackItemStatus.countered);
    } else if (action == 'rename') {
      _renameItem(context, ref, item);
    }
  }

  Future<void> _renameItem(
    BuildContext context,
    WidgetRef ref,
    StackItem item,
  ) async {
    final card = await showStackCardPickerDialog(
      context,
      title: 'Rename',
      initialQuery: item.name,
    );
    if (card == null || !context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ref.read(gameProvider.notifier).renameStackItem(
            item.id,
            card.name,
            oracleText: card.oracleText,
            manaCost: card.manaCost,
            imageUrl: card.imageUrl,
            typeLine: card.typeLine,
          );
    });
  }

  void _showOracleText(BuildContext context, StackItem item) {
    final text = item.oracleText?.trim();
    if (text == null || text.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (item.typeLine != null && item.typeLine!.isNotEmpty) ...[
                SizedBox(height: LayoutTokens.gr1),
                Text(
                  item.typeLine!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
              if (item.manaCost != null && item.manaCost!.isNotEmpty) ...[
                SizedBox(height: LayoutTokens.gr1),
                ManaCostPips(manaCost: item.manaCost, symbolHeight: 18),
              ],
              SizedBox(height: LayoutTokens.gr2),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppTheme.textPrimary.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackItemActions extends StatelessWidget {
  final GameStateNotifier notifier;
  final String itemId;
  final bool isFizzled;
  final bool labeled;
  final bool showResolveRespond;
  final bool showFizzleToggle;
  final VoidCallback onRespond;

  const _StackItemActions({
    required this.notifier,
    required this.itemId,
    required this.isFizzled,
    required this.labeled,
    required this.showResolveRespond,
    required this.showFizzleToggle,
    required this.onRespond,
  });

  void _toggleFizzle() {
    notifier.setStackItemStatus(
      itemId,
      isFizzled ? StackItemStatus.active : StackItemStatus.fizzled,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (labeled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showResolveRespond) ...[
            TextButton(
              onPressed: () => notifier.setStackItemStatus(
                itemId,
                StackItemStatus.resolved,
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.success,
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
              ),
              child: const Text('Resolve'),
            ),
            TextButton(
              onPressed: onRespond,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.accent,
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
              ),
              child: const Text('Respond'),
            ),
          ],
          if (showFizzleToggle)
            TextButton(
              onPressed: _toggleFizzle,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.dangerAmber,
                backgroundColor: isFizzled
                    ? AppTheme.dangerAmber.withValues(alpha: 0.22)
                    : null,
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
              ),
              child: Text(isFizzled ? 'Fizzled' : 'Fizzle'),
            ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showResolveRespond) ...[
          IconButton(
            tooltip: 'Resolve',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.success,
              size: 22,
            ),
            onPressed: () => notifier.setStackItemStatus(
              itemId,
              StackItemStatus.resolved,
            ),
          ),
          IconButton(
            tooltip: 'Respond',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.reply_rounded,
              color: AppTheme.accent,
              size: 22,
            ),
            onPressed: onRespond,
          ),
        ],
        if (showFizzleToggle)
          IconButton(
            tooltip: isFizzled ? 'Undo fizzle' : 'Fizzle',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: isFizzled
                  ? AppTheme.dangerAmber.withValues(alpha: 0.22)
                  : null,
            ),
            icon: Icon(
              Icons.not_interested_rounded,
              color: AppTheme.dangerAmber,
              size: 22,
            ),
            onPressed: _toggleFizzle,
          ),
      ],
    );
  }
}
