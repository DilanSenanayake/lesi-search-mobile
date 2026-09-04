import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/lesi_theme.dart';
import '../widgets/app_web_view.dart';
import '../widgets/app_web_view_types.dart';
import '../widgets/common.dart';

Future<void> openInAppBrowser(
  BuildContext context, {
  required String url,
  String? title,
}) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    showErrorSnack(context, 'This link cannot be opened.');
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => InAppBrowserScreen(
        initialUrl: uri.toString(),
        title: title,
      ),
    ),
  );
}

class InAppBrowserScreen extends StatefulWidget {
  const InAppBrowserScreen({
    super.key,
    required this.initialUrl,
    this.title,
  });

  final String initialUrl;
  final String? title;

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late String _currentUrl;
  AppWebViewHandle? _handle;
  var _loading = true;
  var _canGoBack = false;
  var _canGoForward = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(fn);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  Future<void> _refreshNav() async {
    final handle = _handle;
    if (handle == null || !mounted) return;
    final back = await handle.canGoBack();
    final forward = await handle.canGoForward();
    if (!mounted) return;
    _safeSetState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: _currentUrl));
    if (!mounted) return;
    showSuccessSnack(context, 'URL copied');
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(_currentUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _reload() async {
    _safeSetState(() {
      _errorMessage = null;
      _loading = true;
    });
    await _handle?.reload();
  }

  Future<bool> _handleSystemBack() async {
    final handle = _handle;
    if (handle != null && await handle.canGoBack()) {
      await handle.goBack();
      await _refreshNav();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handleSystemBack();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: LesiTheme.bg,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title?.trim().isNotEmpty == true
                    ? widget.title!.trim()
                    : 'Listing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _hostLabel(_currentUrl),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: LesiTheme.muted,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Back',
              onPressed: _canGoBack
                  ? () async {
                      await _handle?.goBack();
                      await _refreshNav();
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            IconButton(
              tooltip: 'Forward',
              onPressed: _canGoForward
                  ? () async {
                      await _handle?.goForward();
                      await _refreshNav();
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ),
            IconButton(
              tooltip: 'Reload',
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) {
                if (value == 'copy') _copyUrl();
                if (value == 'external') _openExternally();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'copy', child: Text('Copy URL')),
                PopupMenuItem(
                  value: 'external',
                  child: Text('Open in browser'),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_loading ? 3 : 1),
            child: _loading
                ? const LinearProgressIndicator(minHeight: 2)
                : Container(height: 1, color: LesiTheme.border),
          ),
        ),
        body: Stack(
          children: [
            AppWebView(
              initialUrl: widget.initialUrl,
              onCreated: (handle) {
                _handle = handle;
                _refreshNav();
              },
              onUrlChanged: (url) {
                _safeSetState(() {
                  _currentUrl = url;
                  _errorMessage = null;
                });
                _refreshNav();
              },
              onLoadingChanged: (loading) {
                _safeSetState(() => _loading = loading);
                _refreshNav();
              },
              onLoadError: (message) {
                _safeSetState(() {
                  _errorMessage = message.trim().isEmpty ? null : message;
                });
              },
            ),
            if (_errorMessage != null)
              Positioned.fill(
                child: ColoredBox(
                  color: LesiTheme.bg.withValues(alpha: 0.96),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 40,
                            color: LesiTheme.muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _reload,
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _openExternally,
                            child: const Text('Open in browser'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _hostLabel(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    return uri.host;
  }
}
