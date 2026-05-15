/// Consistent font sizes — **multiples of 4** for alignment with the 4dp layout grid.
/// Pair with [FontWeight] on [TextStyle] for hierarchy when two slots share a size.
class FontTokens {
  FontTokens._();

  /// Tiny emphasis (8)
  static const double xs = 8;

  /// Small / compact (12)
  static const double sm = 12;

  /// Captions, secondary (12)
  static const double caption = 12;

  /// Labels (12) — use [FontWeight.w700] vs body when both are 12.
  static const double label = 12;

  /// Body (16)
  static const double body = 16;

  /// Tile / section titles (16) — use weight/letterSpacing vs [body].
  static const double title = 16;

  /// Primary body / buttons (16)
  static const double bodyLg = 16;

  /// Screen titles (20)
  static const double headline = 20;
}
