import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/utils/profile_avatar_storage.dart';

void main() {
  group('isLocalAvatarRef', () {
    test('detects absolute paths and file URIs', () {
      expect(isLocalAvatarRef('/data/user/0/app/avatar.jpg'), isTrue);
      expect(isLocalAvatarRef(r'C:\Users\me\avatar.png'), isTrue);
      expect(isLocalAvatarRef('file:///tmp/avatar.jpg'), isTrue);
    });

    test('rejects network and empty refs', () {
      expect(isLocalAvatarRef(null), isFalse);
      expect(isLocalAvatarRef(''), isFalse);
      expect(isLocalAvatarRef('https://cards.scryfall.io/art.jpg'), isFalse);
      expect(isLocalAvatarRef('http://example.com/a.png'), isFalse);
    });
  });

  group('localFileFromRef', () {
    test('returns null for network urls', () {
      expect(
        localFileFromRef('https://cards.scryfall.io/art.jpg'),
        isNull,
      );
    });

    test('returns file when path exists', () async {
      final dir = await Directory.systemTemp.createTemp('avatar_ref_');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      final file = File('${dir.path}/face.jpg');
      await file.writeAsBytes(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]));
      expect(localFileFromRef(file.path), isNotNull);
      expect(localFileFromRef('${dir.path}/missing.jpg'), isNull);
    });
  });

  group('encodeLocalAvatarForBackup', () {
    test('encodes existing local file as base64', () async {
      final dir = await Directory.systemTemp.createTemp('avatar_enc_');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      final file = File('${dir.path}/face.png');
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      await file.writeAsBytes(bytes);

      final encoded = await encodeLocalAvatarForBackup(file.path);
      expect(encoded, isNotNull);
      expect(encoded!.mime, 'image/png');
      expect(base64Decode(encoded.base64), bytes);
    });

    test('returns null for network avatar', () async {
      expect(
        await encodeLocalAvatarForBackup('https://example.com/a.jpg'),
        isNull,
      );
    });
  });
}
