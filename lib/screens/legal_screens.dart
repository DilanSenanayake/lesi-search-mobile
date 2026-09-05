import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../legal/legal_copy.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';
import 'in_app_browser_screen.dart';

/// Hub for Terms, Privacy, version info, and account-deletion web link.
class AboutLegalScreen extends StatelessWidget {
  const AboutLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: 'About & Legal',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('LesiSearch', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'AI-ranked vehicle search for Sri Lanka.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            LegalCopy.versionLabel,
            style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
          ),
          Text(
            'Legal last updated: ${LegalCopy.lastUpdated}',
            style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
          ),
          const SizedBox(height: 28),
          Text('Legal', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _LegalTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => Navigator.of(context).pushNamed('/legal/terms'),
          ),
          _LegalTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.of(context).pushNamed('/legal/privacy'),
          ),
          const SizedBox(height: 24),
          Text('Account deletion', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Signed-in users can delete their account under Profile → Delete account. '
            'You can also use the web instructions below (required backup for Play Store).',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _LegalTile(
            icon: Icons.open_in_new_rounded,
            title: 'Account deletion (web)',
            onTap: () => openInAppBrowser(
              context,
              url: LegalCopy.accountDeletionWebUrl,
              title: 'Delete account',
            ),
          ),
          const SizedBox(height: 24),
          Text('Help improve LesiSearch', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _LegalTile(
            icon: Icons.feedback_outlined,
            title: 'Share your feedback',
            onTap: () => Navigator.of(context).pushNamed('/feedback'),
          ),
          const SizedBox(height: 24),
          Text(
            'Questions: ${LegalCopy.contactEmail}',
            style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
          ),
        ],
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MarkdownLegalPage(
      title: 'Terms & Conditions',
      markdown: LegalCopy.termsMarkdown,
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MarkdownLegalPage(
      title: 'Privacy Policy',
      markdown: LegalCopy.privacyMarkdown,
    );
  }
}

class _MarkdownLegalPage extends StatelessWidget {
  const _MarkdownLegalPage({
    required this.title,
    required this.markdown,
  });

  final String title;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: title,
      child: Markdown(
        data: markdown,
        selectable: true,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: textTheme.bodyMedium,
          h1: textTheme.headlineSmall,
          h2: textTheme.titleMedium,
          blockquote: textTheme.bodySmall?.copyWith(
            color: LesiTheme.inkSoft,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            color: LesiTheme.accentSoft.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(LesiTheme.rSm),
          ),
          listBullet: textTheme.bodyMedium,
        ),
        onTapLink: (text, href, title) async {
          if (href == null || href.isEmpty) return;
          final uri = Uri.tryParse(href);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LesiTheme.surface,
      borderRadius: BorderRadius.circular(LesiTheme.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LesiTheme.rMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: LesiTheme.accentDark, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: LesiTheme.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
