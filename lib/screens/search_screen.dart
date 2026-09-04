import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_state.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';
import '../widgets/feedback_section.dart';
import '../widgets/filter_form.dart';
import 'alerts_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _model = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  String _vehicleType = 'car';
  String _make = 'Toyota';
  String _location = '';
  int? _minYear;
  int? _maxYear;
  bool _more = false;
  bool _searching = false;

  @override
  void dispose() {
    _model.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  SearchFilters _filters() {
    return SearchFilters(
      make: _make.isEmpty ? null : _make,
      model: _model.text,
      location: _location.isEmpty ? null : _location,
      vehicleType: _vehicleType.isEmpty ? 'any' : _vehicleType,
      minPrice: int.tryParse(_minPrice.text.replaceAll(',', '')),
      maxPrice: int.tryParse(_maxPrice.text.replaceAll(',', '')),
      minYear: _minYear,
      maxYear: _maxYear,
      maxPages: 3,
    );
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    try {
      final result = await context.read<ApiClient>().evaluate(_filters());
      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        '/results',
        arguments: {'result': result, 'filters': _filters()},
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        await context.read<AuthState>().handleUnauthorized();
        if (!mounted) return;
      }
      showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      bottom: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Alerts',
                icon: Icons.notifications_outlined,
                onPressed: _searching
                    ? null
                    : () => openAlertsFlow(context, filters: _filters()),
                expanded: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Search with AI',
                icon: Icons.auto_awesome_rounded,
                loading: _searching,
                gradient: true,
                onPressed: _searching ? null : _search,
              ),
            ),
          ],
        ),
      ),
      child: AiLoadingOverlay(
        visible: _searching,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Find your vehicle', style: textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Set filters and let AI rank the best matches across listing sites.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              elevated: true,
              padding: const EdgeInsets.all(18),
              child: SearchFilterForm(
                key: ValueKey(
                  '$_vehicleType|$_make|$_location|$_minYear|$_maxYear|$_more',
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
            if (!auth.isAuthenticated) ...[
              const SizedBox(height: 16),
              Material(
                color: LesiTheme.accentSoft.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(LesiTheme.rMd),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/register'),
                  borderRadius: BorderRadius.circular(LesiTheme.rMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: LesiTheme.accentDark,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Create a free account for new listing alerts.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: LesiTheme.ink,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: LesiTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const FeedbackSection(),
          ],
        ),
      ),
    );
  }
}
