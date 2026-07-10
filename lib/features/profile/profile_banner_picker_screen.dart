import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/scryfall_service.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';

/// Pick MTG card art for the circular profile picture.
///
/// The hero banner itself is a fixed default graphic (not user-selectable)
/// so it never duplicates the same card art shown here — see
/// `_defaultProfileBannerArt` in `profile_screen.dart`.
class ProfilePicturePickerScreen extends ConsumerStatefulWidget {
  const ProfilePicturePickerScreen({super.key});

  @override
  ConsumerState<ProfilePicturePickerScreen> createState() =>
      _ProfilePicturePickerScreenState();
}

class _ProfilePicturePickerScreenState
    extends ConsumerState<ProfilePicturePickerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<ScryfallCard> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

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
      final results = await service.searchCards(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        if (results.isEmpty) _error = 'No cards found for "$query"';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _error =
            'Unable to search. Check your internet connection and try again.';
      });
    }
  }

  void _returnToProfile() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _applyAndReturn(String? imageUrl) async {
    final profile = ref.read(profileRepositoryProvider).getProfile();
    if (profile == null) return;
    profile.profileAvatarImageUrl = imageUrl;
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    if (!mounted) return;
    // Navigate home before refreshing router listeners (avoids stack glitch).
    context.go(AppRoutes.home);
    bumpProfileRevision(ref);
  }

  Future<void> _useCommanderPortrait() async {
    final profile = ref.read(profileRepositoryProvider).getProfile();
    final url = profile?.selectedCommanderImageUrl;
    if (url == null || url.isEmpty) return;
    await _applyAndReturn(url);
  }

  Future<void> _onCardTap(ScryfallCard card) async {
    if (card.imageUrl == null || card.imageUrl!.isEmpty) return;
    await _applyAndReturn(card.imageUrl);
  }

  Future<void> _clearImage() async {
    await _applyAndReturn(null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final profile = ref.watch(profileRepositoryProvider).getProfile();
    final commanderUrl = profile?.selectedCommanderImageUrl;
    final canUseCommander = commanderUrl != null && commanderUrl.isNotEmpty;

    return Scaffold(
      appBar: UiAppBar(
        title: 'Profile picture',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToProfile,
        ),
        actions: [
          if (canUseCommander)
            TextButton(
              onPressed: _useCommanderPortrait,
              child: Text(
                'Commander',
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton(
            onPressed: _clearImage,
            child: Text(
              'Remove',
              style: TextStyle(
                color: ColorTokens.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: colors.backgroundPrimary,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(LayoutTokens.gr3),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search MTG cards for profile picture…',
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colors.textSecondary,
                        ),
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
              style: TextStyle(color: colors.textPrimary),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(child: _buildResults(context)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final colors = AppColorTokens.of(context);
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primaryAccent),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: Text(
            _error!,
            style: TextStyle(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_results.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: Text(
            'Search for a card—its art becomes your profile picture.',
            style: TextStyle(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final w = MediaQuery.sizeOf(context).width;
    final crossAxisCount = w < 320 ? 1 : 2;
    final aspectRatio = w < 320 ? 0.75 : (w < 360 ? 0.68 : 0.72);

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        w < 360 ? LayoutTokens.gr2 : LayoutTokens.gr3,
        0,
        w < 360 ? LayoutTokens.gr2 : LayoutTokens.gr3,
        LayoutTokens.gr4,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: w < 360 ? 8 : 10,
        mainAxisSpacing: w < 360 ? 8 : 10,
      ),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final card = _results[i];
        return _CardArtTile(
          card: card,
          onTap: () => _onCardTap(card),
        );
      },
    );
  }
}

class _CardArtTile extends StatelessWidget {
  final ScryfallCard card;
  final VoidCallback onTap;

  const _CardArtTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: card.imageUrl != null ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.borderSubtle.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  child: card.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: card.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholder(context),
                        )
                      : _placeholder(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 360 ? 6 : 8),
                child: Text(
                  card.name,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: MediaQuery.sizeOf(context).width < 360 ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Icon(Icons.style, color: colors.textMuted, size: 32),
      ),
    );
  }
}
