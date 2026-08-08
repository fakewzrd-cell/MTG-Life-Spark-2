import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const _kAvatarDirName = 'profile_avatars';

/// True when [ref] points at a local file (absolute path or `file://` URI).
bool isLocalAvatarRef(String? ref) {
  if (ref == null || ref.isEmpty) return false;
  if (ref.startsWith('file://')) return true;
  if (ref.startsWith('http://') || ref.startsWith('https://')) return false;
  // Absolute filesystem paths (Android/iOS/desktop).
  if (ref.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(ref)) {
    return true;
  }
  return false;
}

/// Resolves a stored avatar ref to a [File], or null if not local / missing.
File? localFileFromRef(String? ref) {
  if (!isLocalAvatarRef(ref)) return null;
  final path = ref!.startsWith('file://')
      ? Uri.parse(ref).toFilePath()
      : ref;
  final file = File(path);
  return file.existsSync() ? file : null;
}

Future<Directory> _avatarDirectory() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/$_kAvatarDirName');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Copies a picked gallery/camera image into app documents.
///
/// Returns the absolute path to store in [PlayerProfile.profileAvatarImageUrl].
Future<String> savePickedAvatar(XFile picked) async {
  final bytes = await picked.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('Selected image was empty.');
  }
  return saveAvatarBytes(bytes, suggestedName: picked.name);
}

/// Writes raw image bytes as a new local avatar file. Returns absolute path.
Future<String> saveAvatarBytes(
  Uint8List bytes, {
  String? suggestedName,
}) async {
  if (bytes.isEmpty) {
    throw StateError('Avatar image bytes were empty.');
  }
  final dir = await _avatarDirectory();
  final ext = _extensionFor(suggestedName) ?? _extensionFromMagic(bytes) ?? 'jpg';
  final name = 'avatar_${const Uuid().v4()}.$ext';
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Deletes a previously stored local avatar when [ref] is local. No-op otherwise.
Future<void> deleteAvatarFile(String? ref) async {
  final file = localFileFromRef(ref);
  if (file == null) return;
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // Best-effort cleanup; ignore missing/locked files.
  }
}

/// Base64 payload for backup export, or null when [ref] is not a readable local file.
Future<({String base64, String mime})?> encodeLocalAvatarForBackup(
  String? ref,
) async {
  final file = localFileFromRef(ref);
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) return null;
  final mime = _mimeForPath(file.path) ?? 'image/jpeg';
  return (base64: base64Encode(bytes), mime: mime);
}

/// Restores a local avatar from backup base64. Returns the new absolute path.
Future<String> restoreAvatarFromBackupBase64(
  String base64, {
  String? mime,
}) async {
  final bytes = base64Decode(base64);
  final ext = switch (mime) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/gif' => 'gif',
    _ => 'jpg',
  };
  return saveAvatarBytes(bytes, suggestedName: 'restore.$ext');
}

String? _extensionFor(String? name) {
  if (name == null || name.isEmpty) return null;
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return null;
  final ext = name.substring(dot + 1).toLowerCase();
  const allowed = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'heic', 'heif'};
  if (!allowed.contains(ext)) return null;
  if (ext == 'jpeg') return 'jpg';
  return ext;
}

String? _extensionFromMagic(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'jpg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'png';
  }
  if (bytes.length >= 4 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46) {
    return 'webp';
  }
  return null;
}

String? _mimeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return null;
}
