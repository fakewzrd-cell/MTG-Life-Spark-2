import 'dart:convert';
import 'dart:io';

/// Writes one NDJSON line for Cursor debug ingest (VM/desktop/mobile only).
void appendSessionNdjson(Map<String, Object?> payload) {
  try {
    File(
      '/Users/federick/MTG/MTG-Life-Spark/.cursor/debug-02a8f6.log',
    ).writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  } catch (_) {}
}
