import 'dart:math';

/// QR / WebSocket join URI helpers for LAN sessions.
///
/// Transport is cleartext `ws://` on the local network by design (same Wi‑Fi
/// pod). Do not reuse join tokens outside a trusted LAN.
///
/// Format: `lifespark://<host>:<port>?token=<secret>`
/// Legacy `mgtlifespark://` QRs are still accepted when scanning.
/// Legacy QRs without `token` are rejected by current hosts.
class SessionJoinUri {
  SessionJoinUri._();

  static const scheme = 'lifespark';

  /// Pre-rebrand QR scheme — accepted on parse only.
  static const legacyScheme = 'mgtlifespark';

  /// URL-safe token for a single host session (regenerated each [startHostSession]).
  static String generateToken() {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(24, (_) => alphabet[rand.nextInt(alphabet.length)])
        .join();
  }

  static String buildQrPayload({
    required String hostIp,
    required int port,
    required String token,
  }) {
    return '$scheme://$hostIp:$port?token=$token';
  }

  /// Parses a scanned QR into WebSocket URI and optional join token.
  static ({String wsUri, String? token}) parse(String raw) {
    final usedScheme = raw.startsWith('$scheme://')
        ? scheme
        : raw.startsWith('$legacyScheme://')
            ? legacyScheme
            : null;
    if (usedScheme == null) {
      throw FormatException('Not a valid Life Spark QR code.');
    }

    final withoutScheme = raw.substring('$usedScheme://'.length);
    final queryIndex = withoutScheme.indexOf('?');
    final authority =
        queryIndex == -1 ? withoutScheme : withoutScheme.substring(0, queryIndex);
    final wsUri = 'ws://$authority';

    String? token;
    if (queryIndex != -1) {
      final query = withoutScheme.substring(queryIndex + 1);
      for (final part in query.split('&')) {
        final eq = part.indexOf('=');
        if (eq <= 0) continue;
        final key = part.substring(0, eq);
        final value = Uri.decodeComponent(part.substring(eq + 1));
        if (key == 'token' && value.isNotEmpty) {
          token = value;
          break;
        }
      }
    }

    return (wsUri: wsUri, token: token);
  }
}
