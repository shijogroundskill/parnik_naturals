import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomerAuthWebView extends StatefulWidget {
  const CustomerAuthWebView({
    super.key,
    required this.authorizationUrl,
    required this.redirectUri,
    this.brandAssetPath = 'assets/images/parnik-logo.png',
  });

  final String authorizationUrl;
  final String redirectUri;
  final String brandAssetPath;

  @override
  State<CustomerAuthWebView> createState() => _CustomerAuthWebViewState();
}

class _CustomerAuthWebViewState extends State<CustomerAuthWebView> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            setState(() => _progress = p / 100.0);
            if (p >= 90 && !_initialLoadDone) _initialLoadDone = true;
          },
          onNavigationRequest: (req) {
            final ru = widget.redirectUri;
            if (ru.isNotEmpty && req.url.startsWith(ru)) {
              Navigator.of(context).pop(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        body: Center(child: Text('Sign-in is not supported in web builds.')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.90),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(null),
          icon: const Icon(Icons.close),
        ),
        title: Image.asset(widget.brandAssetPath, height: 22),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress >= 1
              ? const SizedBox(height: 2)
              : LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  color: cs.primary,
                  minHeight: 2,
                ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          AnimatedOpacity(
            opacity: _initialLoadDone ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: _initialLoadDone,
              child: Container(
                color: const Color(0xFFF7F8F7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9EEE9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Opening secure sign-in…',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

