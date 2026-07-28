import 'dart:math';

import 'package:uuid/uuid.dart';

/// Stable seat / network identity for this install's profile.
String generatePlayerId() => const Uuid().v4();

/// Fun default display name when the user skips setup.
/// Format: `Spark` + 4 hex chars, e.g. `SparkA3F2`.
String generateSparkDisplayName([Random? random]) {
  final r = random ?? Random();
  final n = r.nextInt(0x10000);
  return 'Spark${n.toRadixString(16).toUpperCase().padLeft(4, '0')}';
}

bool isPlaceholderDisplayName(String username) {
  final t = username.trim();
  if (t.isEmpty) return true;
  if (t.toLowerCase() == 'planeswalker') return true;
  return false;
}
