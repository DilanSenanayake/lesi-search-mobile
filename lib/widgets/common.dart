import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_state.dart';
import '../theme/lesi_theme.dart';

/// Clean top bar: brand left, single account affordance right.
class LesiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LesiAppBar({super.key, this.showBack = false, this.title});

  final bool showBack;
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      titleSpacing: showBack ? 0 : LesiTheme.s4,
      title: title != null
          ? Text(title!)
          : GestureDetector(
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Row(
                children: [
                  _BrandMark(size: 32),
                  SizedBox(width: 10),
                  Text(
                    'LesiSearch',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                      color: LesiTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        if (!auth.isAuthenticated)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Account',
              onPressed: () => _showGuestAccountSheet(context),
              icon: const Icon(Icons.person_outline_rounded),
              style: IconButton.styleFrom(
                foregroundColor: LesiTheme.ink,
                backgroundColor: LesiTheme.surfaceMuted,
                minimumSize: const Size(40, 40),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _AccountButton(
              label: auth.user?.fullName.isNotEmpty == true
                  ? auth.user!.fullName.characters.first.toUpperCase()
                  : (auth.user?.email.isNotEmpty == true
                      ? auth.user!.email.characters.first.toUpperCase()
                      : 'A'),
              onTap: () => Navigator.of(context).pushNamed('/profile'),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: LesiTheme.border),
      ),
    );
  }
}

void _showGuestAccountSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: LesiTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(LesiTheme.rLg)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LesiTheme.borderStrong,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your account',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to manage alerts and save your preferences.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Sign in',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/login');
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Create account',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/register');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/legal');
                },
                child: const Text('About & Legal'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LesiTheme.aiGradient,
        borderRadius: BorderRadius.circular(LesiTheme.rSm),
        boxShadow: LesiTheme.shadowSm,
      ),
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LesiTheme.accentSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: LesiTheme.accentDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LesiPage extends StatelessWidget {
  const LesiPage({
    super.key,
    required this.child,
    this.showBack = false,
    this.title,
    this.bottom,
    this.floatingActionButton,
  });

  final Widget child;
  final bool showBack;
  final String? title;
  final Widget? bottom;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LesiAppBar(showBack: showBack, title: title),
      floatingActionButton: floatingActionButton,
      body: child,
      bottomNavigationBar: bottom,
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LesiTheme.s4),
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LesiTheme.surface,
        borderRadius: BorderRadius.circular(LesiTheme.rMd),
        border: Border.all(color: LesiTheme.border),
        boxShadow: elevated ? LesiTheme.shadowSm : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LesiTheme.rMd),
        child: content,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.gradient = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (gradient) {
      final enabled = onPressed != null && !loading;
      final button = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(LesiTheme.rSm),
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled ? LesiTheme.aiGradient : null,
              color: enabled ? null : LesiTheme.accent.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(LesiTheme.rSm),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: LesiTheme.accent.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
      return expanded ? SizedBox(width: double.infinity, child: button) : button;
    }

    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      child: child,
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Sticky bottom action bar for primary CTAs.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LesiTheme.surface,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: LesiTheme.border)),
          color: LesiTheme.surface,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: LesiTheme.inkSoft,
            ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LesiTheme.s8, horizontal: LesiTheme.s2),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: LesiTheme.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LesiTheme.accent, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}

class AiLoadingOverlay extends StatelessWidget {
  const AiLoadingOverlay({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visible)
          const Positioned.fill(
            child: _AiSearchLoadingPanel(),
          ),
      ],
    );
  }
}

class _AiSearchLoadingPanel extends StatefulWidget {
  const _AiSearchLoadingPanel();

  @override
  State<_AiSearchLoadingPanel> createState() => _AiSearchLoadingPanelState();
}

class _AiSearchLoadingPanelState extends State<_AiSearchLoadingPanel>
    with TickerProviderStateMixin {
  static const _labels = [
    'Gathering listings',
    'Scoring matches',
    'Ranking with AI',
  ];
  static const _icons = [
    Icons.travel_explore_rounded,
    Icons.analytics_outlined,
    Icons.auto_awesome_rounded,
  ];

  late final AnimationController _pulse;
  late final AnimationController _stepper;
  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _stepper = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )
      ..addListener(() {
        final next =
            (_stepper.value * _labels.length).floor().clamp(0, _labels.length - 1);
        if (next != _activeStep) {
          setState(() => _activeStep = next);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _stepper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: LesiTheme.bg.withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform(_pulse.value);
                  return SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.85 + (t * 0.35),
                          child: Opacity(
                            opacity: (1 - t) * 0.55,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: LesiTheme.accent.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: LesiTheme.aiGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: LesiTheme.accent.withValues(alpha: 0.28),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                'Finding your best matches',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This can take up to a minute while we scan listing sites.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(999)),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: LesiTheme.accentSoft,
                  color: LesiTheme.accent,
                ),
              ),
              const SizedBox(height: 28),
              ...List.generate(_labels.length, (i) {
                final done = i < _activeStep;
                final active = i == _activeStep;
                final color =
                    done || active ? LesiTheme.accent : LesiTheme.muted;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: done
                              ? LesiTheme.accent
                              : active
                                  ? LesiTheme.accentSoft
                                  : LesiTheme.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          done ? Icons.check_rounded : _icons[i],
                          size: 18,
                          color: done ? Colors.white : color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _labels[i],
                          style: textTheme.titleSmall?.copyWith(
                            color: color,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (active)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LesiTheme.accent,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kept for compatibility with older call sites.
class AiSearchButton extends StatelessWidget {
  const AiSearchButton({
    super.key,
    required this.onPressed,
    this.label = 'Search with AI',
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      icon: Icons.search_rounded,
      onPressed: onPressed,
      expanded: !compact,
      gradient: true,
    );
  }
}

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: LesiTheme.danger,
    ),
  );
}

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: LesiTheme.success,
    ),
  );
}
