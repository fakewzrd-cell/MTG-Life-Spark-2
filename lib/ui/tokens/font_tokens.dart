/// Consistent font sizes — **multiples of 4** for alignment with the 4dp layout grid.
/// Pair with [FontWeight] on [TextStyle] for hierarchy when two slots share a size.
///
/// HUD slots ([hudXs], [hudSm]) align to M3 label scale (12/14) on the 4dp grid.
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

  // ── HUD / game compact slots ──────────────────────────────────────────────

  /// Compact HUD micro-label (12). M3 labelSmall floor for in-game text.
  static const double hudXs = 12;

  /// Compact HUD secondary label (14). M3 labelLarge for phase/turn banners.
  static const double hudSm = 14;

  // ── Body / UI ─────────────────────────────────────────────────────────────

  /// Body (16)
  static const double body = 16;

  /// Tile / section titles (16) — use weight/letterSpacing vs [body].
  static const double title = 16;

  /// Primary body / buttons (16)
  static const double bodyLg = 16;

  /// Screen titles (20)
  static const double headline = 20;

  // ── Hero display — game screens ───────────────────────────────────────────

  /// Commander name hero display (36).
  static const double displayCommander = 36;

  /// Life total hero display (56).
  static const double displayLife = 56;
}
