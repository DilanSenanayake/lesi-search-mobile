import 'package:flutter/material.dart';

/// Platform webview handle used by the in-app browser chrome.
abstract class AppWebViewHandle {
  Future<void> reload();
  Future<bool> canGoBack();
  Future<void> goBack();
  Future<bool> canGoForward();
  Future<void> goForward();
}

typedef AppWebViewCreated = void Function(AppWebViewHandle handle);
typedef AppWebViewUrlChanged = void Function(String url);
typedef AppWebViewLoadingChanged = void Function(bool isLoading);
typedef AppWebViewLoadError = void Function(String message);

/// Shared constructor shape for platform webview widgets.
abstract class AppWebViewBase extends StatefulWidget {
  const AppWebViewBase({
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
}
