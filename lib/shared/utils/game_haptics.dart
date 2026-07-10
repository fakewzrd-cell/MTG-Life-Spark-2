import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/haptic_service.dart';

/// Tabletop haptics gated by user settings — no-op when [ProviderScope] is absent (tests).
extension GameHapticsContext on BuildContext {
  void gameHapticLight() => _runGameHaptic(this, (s) => s.light());

  void gameHapticSelection() => _runGameHaptic(this, (s) => s.selection());

  void gameHapticMedium() => _runGameHaptic(this, (s) => s.medium());
}

void _runGameHaptic(
  BuildContext context,
  Future<void> Function(HapticService service) action,
) {
  try {
    final container = ProviderScope.containerOf(context, listen: false);
    action(container.read(hapticServiceProvider));
  } on StateError {
    // Widget tests without ProviderScope.
  }
}
