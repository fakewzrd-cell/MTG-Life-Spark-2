import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/tokens/layout_tokens.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final profile = PlayerProfile(username: _usernameController.text.trim());
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);

    if (mounted) context.go(AppRoutes.onboarding);
  }

  Future<void> _skip() async {
    setState(() => _saving = true);
    final profile = PlayerProfile(username: 'Planeswalker');
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);
    if (mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
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
                      SizedBox(height: LayoutTokens.gr5),
                      Center(
                        child: Column(
                          children: [
                            const BrandLogo(
                              layout: BrandLogoLayout.vertical,
                              height: 140,
                            ),
                            SizedBox(height: LayoutTokens.gr4),
                            Text(
                              'Commander 2.0 — your digital battlefield.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr5),
                      Text(
                        'Create your profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: LayoutTokens.gr1),
                      Text(
                        'Choose a name your opponents will fear.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: LayoutTokens.gr4),
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
                      label: 'Enter the Battlefield',
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
