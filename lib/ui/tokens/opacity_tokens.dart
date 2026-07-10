/// Opacity scale for `.withValues(alpha: …)` calls.
///
/// Values sit on standard 5% increments with named semantic slots so that
/// tinting, disabling, and layering remain consistent across the codebase.
class OpacityTokens {
  OpacityTokens._();

  // ── Named semantic slots ──────────────────────────────────────────────────

  /// Barely-there tint — background glow, pressed ripple (0.08).
  static const double faint = 0.08;

  /// Subtle tint — selected/hover background (0.12).
  static const double subtle = 0.12;

  /// Soft fill — pill/chip background, inactive indicator (0.20).
  static const double soft = 0.20;

  /// Moderate tint — border overlays, dividers (0.30).
  static const double moderate = 0.30;

  /// Half — disabled text, inactive icons (0.50).
  static const double half = 0.50;

  /// Strong — overlays, scrim (0.75).
  static const double strong = 0.75;

  /// Near-opaque — almost solid but slightly blended (0.90).
  static const double nearOpaque = 0.90;

  // ── M3 state layers (dark theme) ──────────────────────────────────────────

  /// Hover overlay (0.08).
  static const double stateHover = faint;

  /// Focus / pressed overlay (0.12).
  static const double stateFocus = subtle;
  static const double statePressed = subtle;

  /// Dragged overlay (0.16).
  static const double stateDragged = 0.16;

  /// Disabled content opacity (0.38).
  static const double disabled = 0.38;

  /// Minimum opacity for muted text on surfaces — WCAG AA floor (0.60).
  static const double mutedTextMin = 0.60;
}
