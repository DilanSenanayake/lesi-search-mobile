import 'package:flutter/material.dart';

import '../legal/legal_copy.dart';
import '../services/legal_acceptance.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';

/// First-run gate: accept Terms & Privacy before using the app.
class TermsAcceptanceScreen extends StatelessWidget {
  const TermsAcceptanceScreen({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  Future<void> _agree() async {
    await LegalAcceptance.acceptCurrent();
    onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: LesiTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LesiTheme.aiGradient,
                    borderRadius: BorderRadius.circular(LesiTheme.rMd),
                    boxShadow: LesiTheme.shadowMd,
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to LesiSearch',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'AI-ranked vehicle search for Sri Lanka. Before you continue, '
                'please review and accept our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: LesiTheme.inkSoft),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/legal/terms'),
                child: const Text('Terms & Conditions'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/legal/privacy'),
                child: const Text('Privacy Policy'),
              ),
              const Spacer(flex: 3),
              Text(
                'By tapping Agree, you accept the Terms & Conditions and Privacy Policy.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'I agree',
                onPressed: _agree,
              ),
              const SizedBox(height: 8),
              Text(
                'Legal last updated: ${LegalCopy.lastUpdated}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
