import 'web_logo_splash_web.dart';

/// Prefer [signalWebAppEntered] from bootstrap after first paint.
void dismissWebSplash() {
  signalWebAppEntered();
}
