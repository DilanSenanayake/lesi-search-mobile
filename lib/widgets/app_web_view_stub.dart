import 'package:flutter/material.dart';

import 'app_web_view_types.dart';

class AppWebView extends StatelessWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.onCreated,
    this.onUrlChanged,
    this.onLoadingChanged,
    this.onLoadError,
  });

  final String initialUrl;
  final AppWebViewCreated? onCreated;
  final AppWebViewUrlChanged? onUrlChanged;
  final AppWebViewLoadingChanged? onLoadingChanged;
  final AppWebViewLoadError? onLoadError;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F8FF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'In-app browsing is not available on this platform. Use Copy or Open externally.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
