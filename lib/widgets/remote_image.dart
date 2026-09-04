import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Network image that works for third-party CDNs (Ikman / Riyasewana).
///
/// On web, CanvasKit cannot decode cross-origin images without CORS, so we
/// prefer an HTML `<img>` element. On mobile/desktop we use cached fetches.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
  });

  final String url;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;

  static String? normalizeUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('//')) return 'https:$value';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = normalizeUrl(url);
    if (resolved == null) {
      return error ?? const SizedBox.shrink();
    }

    final fallback = error ?? const SizedBox.shrink();
    final loading = placeholder ?? const SizedBox.shrink();

    if (kIsWeb) {
      return Image.network(
        resolved,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return loading;
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      placeholder: (_, __) => loading,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
