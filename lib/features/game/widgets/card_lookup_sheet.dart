import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/debug/app_log.dart';
import '../../../core/game/scryfall_service.dart';
import '../../../shared/mana/mana_symbol_assets.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../shared/widgets/mana_cost_pips.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Opens mid-match Scryfall lookup: search → oracle text + official rulings.
Future<void> showCardLookupSheet(BuildContext context) {
  return showGameBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _CardLookupSheet(),
  );
}

class _CardLookupSheet extends ConsumerStatefulWidget {
  const _CardLookupSheet();

  @override
  ConsumerState<_CardLookupSheet> createState() => _CardLookupSheetState();
}

class _CardLookupSheetState extends ConsumerState<_CardLookupSheet> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  List<ScryfallCard> _results = [];
  ScryfallCard? _selected;
  List<ScryfallRuling> _rulings = const [];
  bool _searching = false;
  bool _loadingDetail = false;
  String? _error;

  /// Cap for the whole sheet — never force this height when content is short.
  static const double _maxSheetFraction = 0.88;

  /// Approx chrome above the results list (handle, title, field, hint, gaps).
  static const double _searchChromeReserve = 220;

  bool get _showingDetail => _selected != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _searching = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final cards = await ref.read(scryfallServiceProvider).searchCards(q);
      if (!mounted) return;
      setState(() {
        _results = cards.take(20).toList();
        _searching = false;
        if (_results.isEmpty) {
          _error = 'No cards found for “$q”.';
        }
      });
    } catch (e, st) {
      appLog('CardLookup: Scryfall search failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _searching = false;
        _results = [];
        _error = 'Could not reach Scryfall. Check your connection.';
      });
    }
  }

  Future<void> _openCard(ScryfallCard card) async {
    context.gameHapticSelection();
    setState(() {
      _selected = card;
      _rulings = const [];
      _loadingDetail = true;
      _error = null;
    });
    final service = ref.read(scryfallServiceProvider);
    final fresh = await service.fetchCardByName(card.name) ?? card;
    final rulings = await service.fetchRulings(fresh.id);
    if (!mounted) return;
    setState(() {
      _selected = fresh;
      _rulings = rulings;
      _loadingDetail = false;
    });
  }

  void _backToSearch() {
    setState(() {
      _selected = null;
      _rulings = const [];
      _loadingDetail = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final screenH = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final maxSheetH = screenH * _maxSheetFraction;

    // System/phone back: detail → search list; search → dismiss sheet only.
    // Without this, back pops the whole modal (or the game route under it).
    return PopScope(
      canPop: !_showingDetail,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showingDetail) {
          _backToSearch();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetH),
          child: GameSheetBody(
            child: !_showingDetail
                ? _buildSearchLayout(colors, maxSheetH)
                : _buildDetailLayout(colors, maxSheetH),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchLayout(AppColorTokens colors, double maxSheetH) {
    final maxListH =
        (maxSheetH - _searchChromeReserve).clamp(120.0, maxSheetH * 0.62);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GameSheetHeader(title: 'Card lookup'),
        SizedBox(height: LayoutTokens.gr2),
        TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onQueryChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search any MTG card…',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.textSecondary,
            ),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _onQueryChanged('');
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colors.textSecondary,
                        ),
                      )
                    : null),
          ),
        ),
        SizedBox(height: LayoutTokens.gr1),
        Text(
          'Oracle text and official rulings from Scryfall.',
          style: GameModalChrome.dialogBodyStyle(context),
        ),
        SizedBox(height: LayoutTokens.gr2),
        LimitedBox(
          maxHeight: maxListH,
          child: _buildSearchBody(colors),
        ),
      ],
    );
  }

  Widget _buildSearchBody(AppColorTokens colors) {
    if (_error != null && _results.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr3),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontTokens.hudSm,
            height: 1.4,
          ),
        ),
      );
    }
    if (_results.isEmpty && !_searching) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr3),
        child: Text(
          'Type a card name to look up rules.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontTokens.hudSm,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      primary: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colors.borderSubtle.withValues(alpha: 0.35),
      ),
      itemBuilder: (context, i) {
        final card = _results[i];
        final mana = manaCostPlainText(card.manaCost ?? '');
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
          title: Text(
            card.name,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: FontTokens.hudSm,
            ),
          ),
          subtitle: card.typeLine == null || card.typeLine!.isEmpty
              ? null
              : Text(
                  card.typeLine!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.caption,
                  ),
                ),
          trailing: mana.isEmpty
              ? null
              : Text(
                  mana,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: FontTokens.caption,
                  ),
                ),
          onTap: () => _openCard(card),
        );
      },
    );
  }

  Widget _buildDetailLayout(AppColorTokens colors, double maxSheetH) {
    final card = _selected!;
    final oracle = card.oracleText?.trim();
    // Sticky handle/back/title stay outside the list so the sheet can still
    // be dragged shut while reading oracle text / rulings.
    const chromeReserve = 120.0;
    final maxBodyH =
        (maxSheetH - chromeReserve).clamp(120.0, maxSheetH * 0.75);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GameSheetHandle(),
        SizedBox(height: LayoutTokens.gr2),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _backToSearch,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Search'),
            style: TextButton.styleFrom(
              foregroundColor: colors.primaryAccent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, LayoutTokens.minTapTarget),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        GameSheetHeader(
          title: card.name,
          showHandle: false,
        ),
        SizedBox(height: LayoutTokens.gr2),
        LimitedBox(
          maxHeight: maxBodyH,
          child: ListView(
            shrinkWrap: true,
            // Lets pull-down at the top dismiss the modal sheet.
            primary: true,
            children: [
              if (card.imageUrl != null && card.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: RadiusTokens.radiusMd,
                  child: AspectRatio(
                    aspectRatio: 63 / 44,
                    child: CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => ColoredBox(
                        color: colors.backgroundSecondary,
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: colors.backgroundSecondary,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: LayoutTokens.gr2),
              ],
              if (card.typeLine != null && card.typeLine!.isNotEmpty)
                Text(
                  card.typeLine!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: FontTokens.hudSm,
                  ),
                ),
              if (card.manaCost != null &&
                  card.manaCost!.trim().isNotEmpty) ...[
                SizedBox(height: LayoutTokens.gr1),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ManaCostPips(manaCost: card.manaCost),
                ),
              ],
              SizedBox(height: LayoutTokens.gr3),
              Text(
                'Oracle text',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: FontTokens.hudSm,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              if (oracle == null || oracle.isEmpty)
                Text(
                  'No oracle text available for this card.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.hudSm,
                    height: 1.4,
                  ),
                )
              else
                Text(
                  oracle,
                  style: TextStyle(
                    color: colors.textPrimary.withValues(alpha: 0.92),
                    fontSize: FontTokens.hudSm,
                    height: 1.45,
                  ),
                ),
              SizedBox(height: LayoutTokens.gr3),
              Text(
                'Rulings',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: FontTokens.hudSm,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              if (_loadingDetail)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_rulings.isEmpty)
                Text(
                  'No official rulings listed for this card.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.hudSm,
                    height: 1.4,
                  ),
                )
              else
                for (var i = 0; i < _rulings.length; i++) ...[
                  if (i > 0) SizedBox(height: LayoutTokens.gr2),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary.withValues(
                        alpha: OpacityTokens.soft,
                      ),
                      borderRadius: RadiusTokens.radiusMd,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(LayoutTokens.gr2),
                      child: Text(
                        _rulings[i].comment,
                        style: TextStyle(
                          color: colors.textPrimary.withValues(alpha: 0.9),
                          fontSize: FontTokens.hudSm,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ],
              SizedBox(height: LayoutTokens.gr2),
            ],
          ),
        ),
      ],
    );
  }
}
