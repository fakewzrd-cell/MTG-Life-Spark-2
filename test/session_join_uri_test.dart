import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/network/session_join_uri.dart';

void main() {
  group('SessionJoinUri', () {
    test('buildQrPayload includes token query param', () {
      final raw = SessionJoinUri.buildQrPayload(
        hostIp: '192.168.1.10',
        port: 27315,
        token: 'abc123',
      );
      expect(raw, 'mgtlifespark://192.168.1.10:27315?token=abc123');
    });

    test('parse extracts ws URI and token', () {
      final parsed = SessionJoinUri.parse(
        'mgtlifespark://192.168.1.10:27315?token=secret%20token',
      );
      expect(parsed.wsUri, 'ws://192.168.1.10:27315');
      expect(parsed.token, 'secret token');
    });

    test('parse without token returns null token', () {
      final parsed = SessionJoinUri.parse('mgtlifespark://10.0.0.5:8080');
      expect(parsed.wsUri, 'ws://10.0.0.5:8080');
      expect(parsed.token, isNull);
    });

    test('parse rejects unknown schemes', () {
      expect(
        () => SessionJoinUri.parse('http://example.com'),
        throwsFormatException,
      );
    });

    test('generateToken produces non-empty strings', () {
      expect(SessionJoinUri.generateToken(), isNotEmpty);
      expect(SessionJoinUri.generateToken(), isNot(equals(SessionJoinUri.generateToken())));
    });
  });
}
