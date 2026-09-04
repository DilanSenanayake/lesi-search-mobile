import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_state.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';
import '../widgets/filter_form.dart';

/// Signed-in users go to Profile → Alert filters.
/// Guests get a full setup screen (filters → email OTP).
Future<void> openAlertsFlow(
  BuildContext context, {
  required SearchFilters filters,
}) async {
  final auth = context.read<AuthState>();
  if (auth.isAuthenticated) {
    await Navigator.of(context).pushNamed(
      '/profile',
      arguments: {
        'scrollToAlerts': true,
        'filters': filters,
      },
    );
    return;
  }

  await Navigator.of(context).pushNamed(
    '/alerts/setup',
    arguments: {'filters': filters},
  );
}

/// Kept for older call sites.
Future<void> showAlertsSheet(
  BuildContext context, {
  required SearchFilters filters,
}) =>
    openAlertsFlow(context, filters: filters);

class GuestAlertsScreen extends StatefulWidget {
  const GuestAlertsScreen({super.key, required this.filters});

  final SearchFilters filters;

  @override
  State<GuestAlertsScreen> createState() => _GuestAlertsScreenState();
}

class _GuestAlertsScreenState extends State<GuestAlertsScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _model = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();

  late String _vehicleType;
  late String _make;
  late String _location;
  int? _minYear;
  int? _maxYear;
  bool _more = true;
  bool _otpSent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final f = widget.filters;
    _vehicleType = (f.vehicleType == 'any') ? '' : f.vehicleType;
    _make = f.make ?? '';
    _model.text = f.model ?? '';
    _location = f.location ?? '';
    _minYear = f.minYear;
    _maxYear = f.maxYear;
    _minPrice.text = f.minPrice?.toString() ?? '';
    _maxPrice.text = f.maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _model.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  SearchFilters _currentFilters() {
    return SearchFilters(
      make: _make.isEmpty ? null : _make,
      model: _model.text,
      location: _location.isEmpty ? null : _location,
      vehicleType: _vehicleType.isEmpty ? 'any' : _vehicleType,
      minPrice: int.tryParse(_minPrice.text.replaceAll(',', '')),
      maxPrice: int.tryParse(_maxPrice.text.replaceAll(',', '')),
      minYear: _minYear,
      maxYear: _maxYear,
    );
  }

  Future<void> _start() async {
    if (_email.text.trim().isEmpty) {
      showErrorSnack(context, 'Enter your email to continue.');
      return;
    }
    setState(() => _busy = true);
    try {
      final msg = await context.read<ApiClient>().startGuestAlerts(
            email: _email.text.trim(),
            filters: _currentFilters(),
          );
      if (!mounted) return;
      setState(() => _otpSent = true);
      showSuccessSnack(context, msg);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_otp.text.trim().length != 6) {
      showErrorSnack(context, 'Enter the 6-digit code from your email.');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<ApiClient>().verifyGuestAlerts(
            email: _email.text.trim(),
            otp: _otp.text.trim(),
          );
      if (!mounted) return;
      showSuccessSnack(context, 'Trial alerts enabled for 2 weeks.');
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: 'Set up alerts',
      bottom: BottomActionBar(
        child: PrimaryButton(
          label: _otpSent ? 'Verify & enable trial' : 'Send verification code',
          loading: _busy,
          onPressed: _busy ? null : (_otpSent ? _verify : _start),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Daily vehicle alerts', style: textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            _otpSent
                ? 'Enter the code sent to ${_email.text.trim()} to enable a 2-week trial.'
                : 'Choose what you want to track, then verify your email for a 2-week trial.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (!_otpSent) ...[
            SurfaceCard(
              elevated: true,
              padding: const EdgeInsets.all(18),
              child: SearchFilterForm(
                key: ValueKey(
                  'guest-$_vehicleType-$_make-$_location-$_more',
                ),
                vehicleType: _vehicleType,
                make: _make,
                modelController: _model,
                location: _location,
                minYear: _minYear,
                maxYear: _maxYear,
                minPriceController: _minPrice,
                maxPriceController: _maxPrice,
                moreFiltersOpen: _more,
                onToggleMore: () => setState(() => _more = !_more),
                onVehicleType: (v) => setState(() => _vehicleType = v),
                onMake: (v) => setState(() => _make = v),
                onLocation: (v) => setState(() => _location = v),
                onMinYear: (v) => setState(() => _minYear = v),
                onMaxYear: (v) => setState(() => _maxYear = v),
              ),
            ),
            const SizedBox(height: 20),
            const FieldLabel('Email'),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),
          ] else ...[
            const FieldLabel('OTP'),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: LesiTheme.ink,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '------',
                counterText: '',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }
}
