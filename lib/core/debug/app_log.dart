import 'package:flutter/foundation.dart';

/// Lightweight app logging (debug/profile builds only).
void appLog(
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  final buffer = StringBuffer('[MTG] $message');
  if (error != null) buffer.write(' — $error');
  debugPrint(buffer.toString());
  if (stackTrace != null) {
    debugPrint(stackTrace.toString());
  }
}
