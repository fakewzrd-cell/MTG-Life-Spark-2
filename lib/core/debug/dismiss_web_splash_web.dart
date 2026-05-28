import 'package:web/web.dart' as web;

void dismissWebSplash() {
  web.document.getElementById('app-loading')?.remove();
}
