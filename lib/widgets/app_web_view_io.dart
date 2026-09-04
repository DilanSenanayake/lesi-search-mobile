import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'app_web_view_types.dart';

bool get _nativeWebViewSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

class AppWebView extends StatefulWidget {
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
  State<AppWebView> createState() => _AppWebViewIoState();
}

class _IoHandle implements AppWebViewHandle {
  _IoHandle(this._controller);

  final WebViewController _controller;

  @override
  Future<void> reload() => _controller.reload();

  @override
  Future<bool> canGoBack() => _controller.canGoBack();

  @override
  Future<void> goBack() => _controller.goBack();

  @override
  Future<bool> canGoForward() => _controller.canGoForward();

  @override
  Future<void> goForward() => _controller.goForward();
}

class _AppWebViewIoState extends State<AppWebView> {
  WebViewController? _controller;
  Widget? _webView;
  var _unsupported = false;
  Timer? _loadTimeout;

  void _setLoading(bool loading) {
    widget.onLoadingChanged?.call(loading);
  }

  void _armLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 30), () {
      if (!mounted) return;
      _setLoading(false);
      widget.onLoadError?.call(
        'This page is taking too long to load. Try reload or open in your browser.',
      );
    });
  }

  void _cancelLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = null;
  }

  Future<void> _configurePlatform(WebViewController controller) async {
    // Use the native WebView user-agent so listing sites serve a normal mobile page.
    await controller.enableZoom(true);

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setUseWideViewPort(true);
      await platform.setMediaPlaybackRequiresUserGesture(false);
      await platform.setVerticalScrollBarEnabled(true);
      await platform.setHorizontalScrollBarEnabled(true);
      await platform.setGeolocationEnabled(true);
      await platform.setMixedContentMode(MixedContentMode.compatibilityMode);

      final cookieManager = WebViewCookieManager();
      final androidCookies = cookieManager.platform;
      if (androidCookies is AndroidWebViewCookieManager) {
        await androidCookies.setAcceptThirdPartyCookies(platform, true);
      }
    } else if (platform is WebKitWebViewController) {
      await platform.setAllowsBackForwardNavigationGestures(true);
    }
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore launch failures (no handler installed).
    }
  }

  Widget _buildWebViewWidget(WebViewController controller) {
    // Hybrid Composition fixes common Android touch/scroll glitches with
    // heavy listing sites (ikman.lk, riyasewana.com).
    if (controller.platform is AndroidWebViewController) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: controller.platform,
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(controller: controller);
  }

  @override
  void initState() {
    super.initState();
    if (!_nativeWebViewSupported) {
      _unsupported = true;
      return;
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(const Color(0xFFF5F8FF));
    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.prevent;
          final scheme = uri.scheme.toLowerCase();
          if (scheme == 'http' ||
              scheme == 'https' ||
              scheme == 'about' ||
              scheme == 'data' ||
              scheme == 'blob') {
            return NavigationDecision.navigate;
          }
          // Phone / WhatsApp / intent links from listing pages.
          _openExternal(uri);
          return NavigationDecision.prevent;
        },
        onProgress: (progress) {
          if (progress > 0 && progress < 100) {
            _setLoading(true);
          } else if (progress >= 100) {
            _cancelLoadTimeout();
            _setLoading(false);
          }
        },
        onPageStarted: (url) {
          _armLoadTimeout();
          _setLoading(true);
          if (url.isNotEmpty) widget.onUrlChanged?.call(url);
        },
        onPageFinished: (url) {
          _cancelLoadTimeout();
          _setLoading(false);
          // Successful document load — clear any earlier transient error UI.
          widget.onLoadError?.call('');
          if (url.isNotEmpty) widget.onUrlChanged?.call(url);
        },
        onWebResourceError: (error) {
          final isMain = error.isForMainFrame ?? true;
          if (!isMain) return;
          _cancelLoadTimeout();
          _setLoading(false);
          final desc = error.description.trim();
          widget.onLoadError?.call(
            desc.isNotEmpty
                ? desc
                : 'Could not load this page. Try reload or open in your browser.',
          );
        },
        // Do not surface HTTP status overlays here. Sites like ikman.lk briefly
        // return 403 during bot/CDN checks, then load normally — showing that
        // as a full-screen error causes a ~3s flash.
        onUrlChange: (change) {
          final url = change.url;
          if (url != null && url.isNotEmpty) {
            widget.onUrlChanged?.call(url);
          }
        },
      ),
    );

    _controller = controller;
    _webView = _buildWebViewWidget(controller);

    () async {
      await _configurePlatform(controller);
      await controller.loadRequest(
        Uri.parse(widget.initialUrl),
        headers: const {
          // Helps some CDNs serve a normal mobile page in WebView.
          'Accept-Language': 'en-US,en;q=0.9',
        },
      );
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCreated?.call(_IoHandle(controller));
      });
    }();
  }

  @override
  void dispose() {
    _cancelLoadTimeout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_unsupported || _controller == null || _webView == null) {
      return const _EmbedFallback(
        message:
            'In-app browsing is available on Android and iOS. Use Copy or Open externally.',
      );
    }
    return SizedBox.expand(child: _webView!);
  }
}

class _EmbedFallback extends StatelessWidget {
  const _EmbedFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F8FF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
