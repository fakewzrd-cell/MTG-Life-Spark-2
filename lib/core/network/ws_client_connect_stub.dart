import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectClientChannel(
  Uri uri, {
  required Duration connectTimeout,
}) {
  return WebSocketChannel.connect(uri);
}
