import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/game/scryfall_service.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/utils/profile_avatar_storage.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/components/ui_snack_bar.dart';

/// Pick MTG card art or an uploaded photo for the circular profile picture.
///
/// The hero banner uses [profileBannerImageUrl] when set, otherwise the bundled
/// default banner art with a dark scrim for readable overlay text.
///
/// When [selectionMode] is true, choosing art (or Remove) pops a [String?]
/// result instead of writing the profile — used by first-time profile setup.
class ProfilePicturePickerScreen extends ConsumerStatefulWidget {
  const ProfilePicturePickerScreen({
    super.key,
    this.selectionMode = false,
    this.initialImageRef,
  });

  /// If true, return the chosen URL via [Navigator.pop] (empty string = clear).
  final bool selectionMode;

  /// Current avatar ref when opening (used to clean up replaced local files).
  final String? initialImageRef;

  @override
  ConsumerState<ProfilePicturePickerScreen> createState() =>
      _ProfilePicturePickerScreenState();
}

class _ProfilePicturePickerScreenState
    extends ConsumerState<ProfilePicturePickerScreen> {
  final _searchController = TextEditingController();
  final _picker = ImagePicker();
  Timer? _debounce;

  List<ScryfallCard> _results = [];
  bool _loading = false;
  bool _pickingPhoto = false;
  String? _error;

  /// Current avatar ref while on this screen (for cleaning up replaced locals).
  String? _currentAvatarRef;

  @override
  void initState() {
    super.initState();
    _currentAvatarRef = widget.initialImageRef ??
        (widget.selectionMode
            ? null
            : ref
                .read(profileRepositoryProvider)
                .getProfile()
                ?.profileAvatarImageUrl);
  }

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
    if (widget.selectionMode) {
      Navigator.of(context).pop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _applyAndReturn(String? imageUrl) async {
    final previous = _currentAvatarRef;
    if (isLocalAvatarRef(previous) && previous != imageUrl) {
      await deleteAvatarFile(previous);
    }
    _currentAvatarRef = imageUrl;

    if (widget.selectionMode) {
      if (!mounted) return;
      // Empty string means "cleared"; null pop is cancel (back).
      Navigator.of(context).pop(imageUrl ?? '');
      return;
    }
    final profile = ref.read(profileRepositoryProvider).getProfile();
    if (profile == null) return;
    profile.profileAvatarImageUrl = imageUrl;
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    if (!mounted) return;
    // Navigate home before refreshing router listeners (avoids stack glitch).
    context.go(AppRoutes.home);
    bumpProfileRevision(ref);
  }

  Future<void> _pickFrom(ImageSource source) async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
      );
      if (picked == null) return;
      final path = await savePickedAvatar(picked);
      if (!mounted) return;
      await _applyAndReturn(path);
    } catch (e) {
      if (!mounted) return;
      showUiSnackBar(
        context,
        'Could not use that photo. Try another image.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
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

  bool get _searchFieldFocused {
    final focus = FocusManager.instance.primaryFocus;
    return focus != null && focus.context != null && focus.hasFocus;
  }

  bool get _keyboardVisible =>
      MediaQuery.viewInsetsOf(context).bottom > 0;

  /// System back / IME hide should not leave the picker while search is open.
  void _onSystemPop(bool didPop) {
    if (didPop) return;
    if (_keyboardVisible || _searchFieldFocused) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    _returnToProfile();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final profile = ref.watch(profileRepositoryProvider).getProfile();
    final commanderUrl = profile?.selectedCommanderImageUrl;
    final canUseCommander = commanderUrl != null && commanderUrl.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onSystemPop(didPop),
      child: Scaffold(
        appBar: UiAppBar(
          title: 'Profile picture',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _returnToProfile,
          ),
          actions: [
            if (canUseCommander && !widget.selectionMode)
              TextButton(
                onPressed: _pickingPhoto ? null : _useCommanderPortrait,
                child: Text(
                  'Commander',
                  style: TextStyle(
                    color: colors.primaryAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            TextButton(
              onPressed: _pickingPhoto ? null : _clearImage,
              child: Text(
                widget.selectionMode ? 'Default' : 'Remove',
                style: TextStyle(
                  color: colors.error,
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
              padding: EdgeInsets.fromLTRB(
                LayoutTokens.gr3,
                LayoutTokens.gr2,
                LayoutTokens.gr3,
                LayoutTokens.gr1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickingPhoto
                          ? null
                          : () => _pickFrom(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Upload photo'),
                    ),
                  ),
                  SizedBox(width: LayoutTokens.gr2),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickingPhoto
                          ? null
                          : () => _pickFrom(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Take photo'),
                    ),
                  ),
                ],
              ),
            ),
            if (_pickingPhoto)
              Padding(
                padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
                child: LinearProgressIndicator(
                  color: colors.primaryAccent,
                  backgroundColor: colors.backgroundSecondary,
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Or search MTG card art',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(LayoutTokens.gr3),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
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
            'Upload a photo, take one, or search for a card—its art becomes your profile picture.',
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
        borderRadius: RadiusTokens.radiusSm,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: RadiusTokens.radiusSm,
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
                    top: Radius.circular(RadiusTokens.sm - 1),
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
                padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 360 ? 6 : 8),
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
