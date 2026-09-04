import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/lesi_theme.dart';
import 'common.dart';

/// Mirrors website Formcarry feedback (`base.html` / `results.html`).
class FeedbackSection extends StatefulWidget {
  const FeedbackSection({
    super.key,
    this.title = 'Share your feedback',
    this.subtitle = 'Tell us what worked and what we should improve.',
    this.placeholder = 'Write your feedback here...',
  });

  final String title;
  final String subtitle;
  final String placeholder;

  static const formcarryUrl = 'https://formcarry.com/s/KUmi1jcB4_s';

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _status;
  bool _success = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      setState(() {
        _success = false;
        _status = 'Please write your feedback before sending.';
      });
      return;
    }

    setState(() {
      _sending = true;
      _success = false;
      _status = 'Sending feedback...';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(FeedbackSection.formcarryUrl),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['message'] = message;
      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _controller.clear();
        setState(() {
          _sending = false;
          _success = true;
          _status = 'Thanks! Your feedback was sent successfully.';
        });
      } else {
        setState(() {
          _sending = false;
          _success = false;
          _status = 'Could not send feedback right now. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _success = false;
        _status = 'Could not send feedback right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(widget.subtitle, style: textTheme.bodySmall),
          const SizedBox(height: 14),
          const FieldLabel('Your feedback'),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(hintText: widget.placeholder),
            enabled: !_sending,
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _sending ? 'Sending...' : 'Send feedback',
            loading: _sending,
            onPressed: _sending ? null : _submit,
          ),
          if (_status != null) ...[
            const SizedBox(height: 10),
            Text(
              _status!,
              style: textTheme.bodySmall?.copyWith(
                color: _success ? LesiTheme.success : LesiTheme.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
