import 'dart:js_interop';

import 'package:web/web.dart' as web;

const _splashDoneEvent = 'lifespark-splash-done';
const _enterAppEvent = 'lifespark-enter-app';

/// Fires [onDone] when the HTML logo video has finished (or already has).
void listenForWebLogoSplashDone(void Function() onDone) {
  final el = web.document.getElementById('app-loading');
  if (el != null && el.getAttribute('data-video-ended') == '1') {
    onDone();
    return;
  }

  late final web.EventListener listener;
  listener = (web.Event _) {
    web.window.removeEventListener(_splashDoneEvent, listener);
    onDone();
  }.toJS;
  web.window.addEventListener(_splashDoneEvent, listener);
}

/// Tell the HTML shell it can remove the logo overlay — the real app is painted.
void signalWebAppEntered() {
  final el = web.document.getElementById('app-loading');
  el?.setAttribute('data-splash-done', '1');
  web.window.dispatchEvent(web.Event(_enterAppEvent));
}
