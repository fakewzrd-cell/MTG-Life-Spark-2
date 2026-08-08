import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/profile_avatar_storage.dart';
import 'default_profile_avatar.dart';

/// Renders a profile avatar from a local file path, network URL, or default art.
class ProfileAvatarImage extends StatelessWidget {
  const ProfileAvatarImage({
    super.key,
    required this.imageRef,
    required this.size,
    this.fit = BoxFit.cover,
  });

  /// Absolute path, `file://` URI, or `http(s)` URL. Null/empty → default.
  final String? imageRef;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final local = localFileFromRef(imageRef);
    if (local != null) {
      return Image.file(
        local,
        width: size,
        height: size,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => DefaultProfileAvatarFill(size: size),
      );
    }

    final url = imageRef?.trim();
    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: fit,
        placeholder: (_, __) => DefaultProfileAvatarFill(size: size),
        errorWidget: (_, __, ___) => DefaultProfileAvatarFill(size: size),
      );
    }

    return DefaultProfileAvatarFill(size: size);
  }
}
