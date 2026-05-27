import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectClientChannel(
  Uri uri, {
  required Duration connectTimeout,
}) {
  return IOWebSocketChannel.connect(
    uri,
    connectTimeout: connectTimeout,
  );
}
