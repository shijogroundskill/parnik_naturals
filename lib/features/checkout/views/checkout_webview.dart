import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebView extends StatefulWidget {
  const CheckoutWebView({
    super.key,
    required this.checkoutUrl,
    this.brandAssetPath = 'assets/images/parnik-logo.png',
  });

  final String checkoutUrl;
  final String brandAssetPath;

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
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
            if (p >= 90 && !_initialLoadDone) {
              _initialLoadDone = true;
            }
          },
          onNavigationRequest: (req) {
            final url = req.url.toLowerCase();
            // Shopify typically lands on /thank_you after a successful order.
            if (url.contains('thank_you') || url.contains('orders')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // WebView isn't supported on Flutter web.
      return const Scaffold(
        body: Center(
          child: Text('Checkout is not supported in web builds.'),
        ),
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
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close),
        ),
        title: Image.asset(
          widget.brandAssetPath,
          height: 22,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Back',
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 4),
        ],
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, 12),
                        ),
                      ],
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
                          'Preparing secure checkout…',
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

