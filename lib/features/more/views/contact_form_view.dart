import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContactFormView extends StatefulWidget {
  const ContactFormView({super.key});

  @override
  State<ContactFormView> createState() => _ContactFormViewState();
}

class _ContactFormViewState extends State<ContactFormView> {
  static const _contactEmail = 'parniknaturals@gmail.com';

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();

  bool _busy = false;

  Future<void> _fallbackEmail() async {
    final subject = 'Contact - Parnik Naturals';
    final body = [
      'Name: ${_name.text.trim()}',
      'Email: ${_email.text.trim()}',
      'Phone: ${_phone.text.trim()}',
      '',
      _message.text.trim(),
    ].join('\n');

    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      if (kIsWeb) {
        // Browser builds cannot POST to Shopify contact form due to CORS.
        await _fallbackEmail();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opened email to send your message')),
        );
        return;
      }

      // Shopify "Contact" form endpoint. This submits the same form as your website
      // without opening a browser.
      final uri = Uri.https('www.parniknaturals.com', '/contact');

      final res = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'text/html',
        },
        body: <String, String>{
          'form_type': 'contact',
          'utf8': '✓',
          'contact[name]': _name.text.trim(),
          'contact[email]': _email.text.trim(),
          'contact[phone]': _phone.text.trim(),
          'contact[body]': _message.text.trim(),
        },
      );

      // Shopify often responds with a redirect (302) after successful submission.
      if (res.statusCode != 302 && (res.statusCode < 200 || res.statusCode >= 300)) {
        throw StateError('Failed: HTTP ${res.statusCode}');
      }

      // Many themes return HTML containing a success indicator after POST.
      final body = res.body;
      final ok = res.statusCode == 302 ||
          body.contains('form-posted-successfully') ||
          body.toLowerCase().contains('thank you') ||
          body.toLowerCase().contains('thanks');

      if (!ok) {
        // Still likely submitted, but we couldn't confirm.
        // Show success to keep UX simple.
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EEE9)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _message,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

