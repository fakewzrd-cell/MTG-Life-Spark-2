import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/components/ui_snack_bar.dart';
import '../../ui/components/ui_text_field.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';

const _kFeedbackEmail = 'federickvidot@gmail.com';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _copyFeedbackFallback(String msg) async {
    final text =
        'To: $_kFeedbackEmail\nSubject: Life Spark Feedback\n\n$msg';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showUiSnackBar(
      context,
      'No mail app — message copied. Paste into an email to $_kFeedbackEmail',
    );
  }

  Future<void> _sendFeedback() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);

    final subject = Uri.encodeComponent('Life Spark Feedback');
    final body = Uri.encodeComponent(msg);
    final uri = Uri.parse(
      'mailto:$_kFeedbackEmail?subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri);
        if (!mounted) return;
        if (launched) {
          showUiSnackBar(context, 'Opening your mail app…');
        } else {
          await _copyFeedbackFallback(msg);
        }
      } else {
        await _copyFeedbackFallback(msg);
      }
    } catch (_) {
      await _copyFeedbackFallback(msg);
    }

    if (mounted) setState(() => _sending = false);
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.lifespark.app',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      appBar: const UiAppBar(title: 'Feedback'),
      backgroundColor: colors.backgroundPrimary,
      body: ListView(
        padding: LayoutTokens.shellListPadding(context, top: LayoutTokens.gr4),
        children: [
          const Center(child: Text('🛡️', style: TextStyle(fontSize: 48))),
          SizedBox(height: LayoutTokens.gr4),
          Text(
            'Help us improve',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: MediaQuery.sizeOf(context).width < 360 ? 22 : 26,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LayoutTokens.gr1),
          Text(
            'Found a bug? Have a feature idea? We read every message.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LayoutTokens.gr5),
          UiTextField(
            controller: _messageController,
            labelText: 'Your message',
            hintText: 'Tell us what you think...',
            maxLines: 6,
            maxLength: 500,
          ),
          SizedBox(height: LayoutTokens.gr4),
          UiButton(
            label: 'Send Feedback',
            icon: _sending ? null : Icon(Icons.send_outlined, size: 20),
            loading: _sending,
            onPressed: _sendFeedback,
          ),
          SizedBox(height: LayoutTokens.gr5),
          Row(
            children: [
              Expanded(child: Divider(color: colors.borderSubtle)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(child: Divider(color: colors.borderSubtle)),
            ],
          ),
          SizedBox(height: LayoutTokens.gr4),
          UiButton(
            label: 'Rate on Play Store',
            variant: UiButtonVariant.secondary,
            icon: Icon(Icons.star_outline, size: 20),
            onPressed: _openPlayStore,
          ),
        ],
      ),
    );
  }
}
