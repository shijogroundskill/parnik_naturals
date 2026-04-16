import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import '../controllers/content_controller.dart';

class ShopifyPageView extends StatefulWidget {
  const ShopifyPageView({
    super.key,
    required this.handle,
    required this.fallbackTitle,
  });

  final String handle;
  final String fallbackTitle;

  @override
  State<ShopifyPageView> createState() => _ShopifyPageViewState();
}

class _ShopifyPageViewState extends State<ShopifyPageView> {
  late final Future<void> _loader;
  String? _title;
  String? _html;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loader = _load();
  }

  Future<void> _load() async {
    try {
      final page = await Get.find<ContentController>().getPage(widget.handle);
      _title = page.title;
      _html = page.bodyHtml;
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loader,
      builder: (context, snap) {
        final title = _title ?? widget.fallbackTitle;
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: snap.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorState(message: _error!, onRetry: () => setState(() {}))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE9EEE9)),
                          ),
                          child: HtmlWidget(
                            _html ?? '',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.35),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

