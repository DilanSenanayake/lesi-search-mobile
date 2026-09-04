// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'app_web_view_types.dart';

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
  State<AppWebView> createState() => _AppWebViewWebState();
}

class _WebHandle implements AppWebViewHandle {
  _WebHandle(this._state);

  final _AppWebViewWebState _state;

  @override
  Future<void> reload() async {
    _state._iframe?.src = _state._currentUrl;
    _state.widget.onLoadingChanged?.call(true);
  }

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<void> goBack() async {}

  @override
  Future<bool> canGoForward() async => false;

  @override
  Future<void> goForward() async {}
}

class _AppWebViewWebState extends State<AppWebView> {
  late final String _viewType;
  html.IFrameElement? _iframe;
  late String _currentUrl;
  var _blockedHint = false;
  Size _lastSize = Size.zero;

  void _sizeIframe(Size size) {
    final iframe = _iframe;
    if (iframe == null || size.isEmpty) return;
    final width = size.width.clamp(1, 4096).round();
    final height = size.height.clamp(1, 8192).round();
    iframe.style
      ..border = 'none'
      ..margin = '0'
      ..padding = '0'
      ..position = 'absolute'
      ..top = '0'
      ..left = '0'
      ..width = '${width}px'
      ..height = '${height}px'
      ..maxWidth = '100%'
      ..maxHeight = '100%'
      ..setProperty('overflow', 'auto');
    iframe.width = '$width';
    iframe.height = '$height';
  }

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _viewType =
        'lesi-inapp-browser-${identityHashCode(this)}-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.initialUrl
        ..allow = 'fullscreen'
        ..allowFullscreen = true
        ..setAttribute('scrolling', 'auto');
      // Hint responsive layouts when sites honor it.
      iframe.setAttribute(
        'style',
        'border:0;margin:0;padding:0;position:absolute;top:0;left:0;width:100%;height:100%;max-width:100%;max-height:100%;overflow:auto;',
      );
      iframe.onLoad.listen((_) {
        widget.onLoadingChanged?.call(false);
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() => _blockedHint = true);
        });
      });
      iframe.onError.listen((_) {
        widget.onLoadingChanged?.call(false);
        if (mounted) setState(() => _blockedHint = true);
      });
      _iframe = iframe;
      if (!_lastSize.isEmpty) {
        _sizeIframe(_lastSize);
      }
      return iframe;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLoadingChanged?.call(true);
      widget.onUrlChanged?.call(widget.initialUrl);
      widget.onCreated?.call(_WebHandle(this));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize && !size.isEmpty) {
          _lastSize = size;
          // Resize outside build to avoid layout feedback loops.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _sizeIframe(size);
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: HtmlElementView(viewType: _viewType),
            ),
            if (_blockedHint)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.96),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Text(
                      'If the page looks blank, the site blocks embedding in browsers. Copy the URL or open it externally.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
