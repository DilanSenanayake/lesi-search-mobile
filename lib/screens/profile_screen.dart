import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../legal/legal_copy.dart';
import '../models/models.dart';
import '../services/auth_state.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';
import 'in_app_browser_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.scrollToAlerts = false,
    this.alertFilters,
  });

  final bool scrollToAlerts;
  final SearchFilters? alertFilters;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scrollController = ScrollController();
  final _alertsKey = GlobalKey();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _model = TextEditingController();
  String _vehicleType = '';
  String _make = '';
  String _location = '';
  int? _minYear;
  int? _maxYear;
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _first.dispose();
    _last.dispose();
    _model.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  void _hydrate(AuthState auth) {
    if (_hydrated) return;
    _hydrated = true;
    final user = auth.user;
    _first.text = user?.firstName ?? '';
    _last.text = user?.lastName ?? '';

    final incoming = widget.alertFilters;
    if (incoming != null) {
      _vehicleType =
          (incoming.vehicleType == 'any') ? '' : incoming.vehicleType;
      _make = incoming.make ?? '';
      _model.text = incoming.model ?? '';
      _location = incoming.location ?? '';
      _minYear = incoming.minYear;
      _maxYear = incoming.maxYear;
      _minPrice.text = incoming.minPrice?.toString() ?? '';
      _maxPrice.text = incoming.maxPrice?.toString() ?? '';
    } else {
      final sub = auth.alertSubscription;
      if (sub != null) {
        final f = sub.filters;
        _vehicleType = (f['vehicle_type'] ?? '').toString();
        if (_vehicleType == 'any') _vehicleType = '';
        _make = (f['make'] ?? '').toString();
        _model.text = (f['model'] ?? '').toString();
        _location = (f['location'] ?? '').toString();
        _minYear = f['min_year'] is int
            ? f['min_year'] as int
            : int.tryParse('${f['min_year'] ?? ''}');
        _maxYear = f['max_year'] is int
            ? f['max_year'] as int
            : int.tryParse('${f['max_year'] ?? ''}');
        _minPrice.text = f['min_price']?.toString() ?? '';
        _maxPrice.text = f['max_price']?.toString() ?? '';
      }
    }

    if (widget.scrollToAlerts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _alertsKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: 0.05,
          );
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthState>();
    final ok = await auth.updateProfile(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnack(context, 'Profile updated.');
    } else {
      showErrorSnack(context, auth.errorMessage ?? 'Update failed');
    }
  }

  Future<void> _saveAlerts() async {
    final auth = context.read<AuthState>();
    final ok = await auth.saveAlerts(
      SearchFilters(
        make: _make.isEmpty ? null : _make,
        model: _model.text,
        location: _location.isEmpty ? null : _location,
        vehicleType: _vehicleType.isEmpty ? 'any' : _vehicleType,
        minPrice: int.tryParse(_minPrice.text.replaceAll(',', '')),
        maxPrice: int.tryParse(_maxPrice.text.replaceAll(',', '')),
        minYear: _minYear,
        maxYear: _maxYear,
      ),
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnack(context, 'Alert filters updated.');
    } else {
      showErrorSnack(context, auth.errorMessage ?? 'Could not save alerts');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      return const LesiPage(child: SizedBox.shrink());
    }
    _hydrate(auth);
    final years = AppConfig.yearChoices();
    final sub = auth.alertSubscription;
    final textTheme = Theme.of(context).textTheme;
    final initial = auth.user?.fullName.isNotEmpty == true
        ? auth.user!.fullName.characters.first.toUpperCase()
        : (auth.user?.email.isNotEmpty == true
            ? auth.user!.email.characters.first.toUpperCase()
            : 'A');

    return LesiPage(
      showBack: true,
      title: 'Profile',
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: LesiTheme.accentSoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: LesiTheme.accentDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.fullName.isNotEmpty == true
                          ? auth.user!.fullName
                          : (auth.user?.email ?? ''),
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      auth.user?.email ?? '',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Your details', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Update the name shown on your account.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('First name'),
                    TextField(
                      controller: _first,
                      decoration: const InputDecoration(hintText: 'First'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Last name'),
                    TextField(
                      controller: _last,
                      decoration: const InputDecoration(hintText: 'Last'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save changes',
            loading: auth.busy,
            onPressed: auth.busy ? null : _saveProfile,
          ),
          const SizedBox(height: 32),
          KeyedSubtree(
            key: _alertsKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alert filters', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  sub?.expiresAt != null
                      ? 'Active until ${sub!.expiresAt!.toLocal().toString().split('.').first}'
                      : 'Filters used for your daily vehicle alerts.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Type'),
          DropdownButtonFormField<String>(
            key: ValueKey('p-vt-$_vehicleType'),
            initialValue: _vehicleType,
            decoration: const InputDecoration(hintText: 'Any type'),
            items: AppConfig.vehicleTypes
                .map(
                  (t) => DropdownMenuItem(
                    value: t.value,
                    child: Text(t.label),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _vehicleType = v ?? ''),
          ),
          const SizedBox(height: 16),
          const FieldLabel('Make'),
          DropdownButtonFormField<String>(
            key: ValueKey('p-make-$_make'),
            initialValue: _make,
            decoration: const InputDecoration(hintText: 'Any make'),
            items: [
              const DropdownMenuItem(value: '', child: Text('Any make')),
              ...AppConfig.makes.map(
                (m) => DropdownMenuItem(value: m, child: Text(m)),
              ),
            ],
            onChanged: (v) => setState(() => _make = v ?? ''),
          ),
          const SizedBox(height: 16),
          const FieldLabel('Model'),
          TextField(
            controller: _model,
            decoration: const InputDecoration(hintText: 'e.g. axio'),
          ),
          const SizedBox(height: 16),
          const FieldLabel('Location'),
          DropdownButtonFormField<String>(
            key: ValueKey('p-loc-$_location'),
            initialValue: _location,
            decoration: const InputDecoration(hintText: 'Any location'),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Any location'),
              ),
              for (final g in AppConfig.locations)
                ...g.places.map(
                  (p) => DropdownMenuItem(value: p, child: Text(p)),
                ),
            ],
            onChanged: (v) => setState(() => _location = v ?? ''),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Min year'),
                    DropdownButtonFormField<int?>(
                      key: ValueKey('p-miny-$_minYear'),
                      initialValue: _minYear,
                      decoration: const InputDecoration(hintText: 'Any'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...years.map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _minYear = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Max year'),
                    DropdownButtonFormField<int?>(
                      key: ValueKey('p-maxy-$_maxYear'),
                      initialValue: _maxYear,
                      decoration: const InputDecoration(hintText: 'Any'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...years.map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _maxYear = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Min price'),
                    TextField(
                      controller: _minPrice,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'e.g. 7500000'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Max price'),
                    TextField(
                      controller: _maxPrice,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'e.g. 9000000'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Save alerts',
            loading: auth.busy,
            onPressed: auth.busy ? null : _saveAlerts,
          ),
          const SizedBox(height: 32),
          SecondaryButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: auth.busy ? null : () => _confirmDeleteAccount(context),
            child: Text(
              'Delete account',
              style: textTheme.titleSmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Permanently removes your LesiSearch account and alert subscriptions. '
            'This cannot be undone. Prefer the in-app delete below; a web backup '
            'link is also listed under Legal & About for Play Store compliance.',
            style: textTheme.bodySmall?.copyWith(color: LesiTheme.muted),
          ),
          const SizedBox(height: 28),
          Text('Legal & About', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Terms, Privacy Policy, app version, and account-deletion info.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/legal'),
            child: const Text('Open About & Legal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/legal/privacy'),
            child: const Text('Privacy Policy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/legal/terms'),
            child: const Text('Terms & Conditions'),
          ),
          TextButton(
            onPressed: () => openInAppBrowser(
              context,
              url: LegalCopy.accountDeletionWebUrl,
              title: 'Delete account (web)',
            ),
            child: const Text('Account deletion (web backup)'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'This permanently deletes your account, profile, and alert '
                'subscriptions. Enter your password to confirm.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    final password = passwordController.text;
    passwordController.dispose();
    if (confirmed != true || !context.mounted) return;
    if (password.isEmpty) {
      showErrorSnack(context, 'Password is required to delete your account.');
      return;
    }

    final auth = context.read<AuthState>();
    final ok = await auth.deleteAccount(password);
    if (!context.mounted) return;
    if (ok) {
      showSuccessSnack(context, 'Your account has been deleted.');
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      showErrorSnack(
        context,
        auth.errorMessage ?? 'Could not delete account.',
      );
    }
  }
}
