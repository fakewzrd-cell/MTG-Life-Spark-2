import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/default_profile_avatar.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import 'profile_picture_picker_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _saving = false;
  String? _avatarUrl;

  static const double _avatarSize = 96;
  static const double _cameraBadgeSize = 28;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await Navigator.of(context, rootNavigator: true).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ProfilePicturePickerScreen(selectionMode: true),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _avatarUrl = result.isEmpty ? null : result);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final profile = PlayerProfile(
      username: _usernameController.text.trim(),
      profileAvatarImageUrl: _avatarUrl,
    );
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);

    if (mounted) context.go(AppRoutes.onboarding);
  }

  Future<void> _skip() async {
    setState(() => _saving = true);
    final profile = PlayerProfile(
      username: 'Planeswalker',
      profileAvatarImageUrl: _avatarUrl,
    );
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);
    if (mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutTokens.ctaHorizontal,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: LayoutTokens.gr6),
                      Text(
                        'Create your profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: LayoutTokens.gr1),
                      Text(
                        'Choose a name and picture your table will recognize.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: LayoutTokens.gr5),
                      Center(
                        child: _SetupAvatarPicker(
                          avatarUrl: _avatarUrl,
                          colors: colors,
                          size: _avatarSize,
                          badgeSize: _cameraBadgeSize,
                          onTap: _saving ? null : _pickAvatar,
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr2),
                      Center(
                        child: TextButton(
                          onPressed: _saving ? null : _pickAvatar,
                          child: Text(
                            _avatarUrl == null
                                ? 'Choose profile picture'
                                : 'Change picture',
                          ),
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr3),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'e.g. The Archduke',
                        ),
                        autofocus: true,
                        maxLength: 20,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a username';
                          }
                          if (v.trim().length < 2) {
                            return 'Must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  LayoutTokens.ctaHorizontal,
                  LayoutTokens.gr2,
                  LayoutTokens.ctaHorizontal,
                  LayoutTokens.gr5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UiButton(
                      label: 'Continue',
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                    SizedBox(height: LayoutTokens.gr2),
                    UiButton(
                      label: 'Skip',
                      variant: UiButtonVariant.secondary,
                      enabled: !_saving,
                      onPressed: _saving ? null : _skip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupAvatarPicker extends StatelessWidget {
  const _SetupAvatarPicker({
    required this.avatarUrl,
    required this.colors,
    required this.size,
    required this.badgeSize,
    this.onTap,
  });

  final String? avatarUrl;
  final AppColorTokens colors;
  final double size;
  final double badgeSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    Widget face;
    if (hasImage) {
      face = CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => DefaultProfileAvatarFill(size: size),
        errorWidget: (_, __, ___) => DefaultProfileAvatarFill(size: size),
      );
    } else {
      face = DefaultProfileAvatarFill(size: size);
    }

    return Semantics(
      button: true,
      label: 'Choose profile picture',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 3,
                  ),
                ),
                child: ClipOval(child: face),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: colors.primaryAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
