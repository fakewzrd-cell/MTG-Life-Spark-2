import 'package:flutter/material.dart';

import '../../../ui/theme/app_color_tokens.dart';

/// Theme-aware colors for the game layer (replaces legacy [AppTheme] statics).
extension GameColors on BuildContext {
  AppColorTokens get gameColors => AppColorTokens.of(this);
}
