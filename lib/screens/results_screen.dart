import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';
import '../widgets/feedback_section.dart';
import '../widgets/filter_form.dart';
import '../widgets/vehicle_card.dart';
import 'alerts_sheet.dart';
import 'in_app_browser_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.result,
    required this.filters,
  });

  final EvaluateResult result;
  final SearchFilters filters;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late EvaluateResult _result;
  late SearchFilters _filters;
  bool _showRefine = false;
  bool _searching = false;

  final _model = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  late String _vehicleType;
  late String _make;
  late String _location;
  int? _minYear;
  int? _maxYear;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _filters = widget.filters;
    _hydrateFromFilters(_filters);
  }

  void _hydrateFromFilters(SearchFilters f) {
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
      maxPages: 3,
    );
  }

  Future<void> _research() async {
    setState(() => _searching = true);
    try {
      final filters = _currentFilters();
      final result = await context.read<ApiClient>().evaluate(filters);
      if (!mounted) return;
      setState(() {
        _result = result;
        _filters = filters;
        _showRefine = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = _result.searchLinks;
    final count = _result.vehicles.length;
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: 'AI Top Picks',
      bottom: BottomActionBar(
        child: PrimaryButton(
          label: 'Turn On Alerts',
          icon: Icons.notifications_outlined,
          onPressed: () => openAlertsFlow(context, filters: _filters),
        ),
      ),
      child: AiLoadingOverlay(
        visible: _searching,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    count == 0
                        ? 'No matches yet'
                        : '$count ranked ${count == 1 ? 'pick' : 'picks'}',
                    style: textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: LesiTheme.accentSoft,
                    borderRadius: BorderRadius.circular(LesiTheme.rSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 13, color: LesiTheme.accent),
                      SizedBox(width: 4),
                      Text(
                        'AI ranked',
                        style: TextStyle(
                          color: LesiTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ranked by value, condition, features, and ownership experience.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterActionChip(
                    label: _showRefine ? 'Close filters' : 'Edit filters',
                    icon: _showRefine
                        ? Icons.close_rounded
                        : Icons.tune_rounded,
                    emphasized: true,
                    onTap: () => setState(() => _showRefine = !_showRefine),
                  ),
                  const SizedBox(width: 8),
                  ..._filterChips(),
                  if (links['riyasewana'] != null) ...[
                    const SizedBox(width: 8),
                    _LinkChip(
                      label: 'Riyasewana',
                      onTap: () => openInAppBrowser(
                        context,
                        url: links['riyasewana'].toString(),
                        title: 'Riyasewana',
                      ),
                    ),
                  ],
                  if (links['ikman'] != null) ...[
                    const SizedBox(width: 8),
                    _LinkChip(
                      label: 'ikman.lk',
                      onTap: () => openInAppBrowser(
                        context,
                        url: links['ikman'].toString(),
                        title: 'ikman.lk',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _showRefine
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SurfaceCard(
                        elevated: true,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            SearchFilterForm(
                              key: ValueKey(
                                'refine-$_vehicleType-$_make-$_location',
                              ),
                              vehicleType: _vehicleType,
                              make: _make,
                              modelController: _model,
                              location: _location,
                              minYear: _minYear,
                              maxYear: _maxYear,
                              minPriceController: _minPrice,
                              maxPriceController: _maxPrice,
                              moreFiltersOpen: true,
                              onToggleMore: null,
                              onVehicleType: (v) =>
                                  setState(() => _vehicleType = v),
                              onMake: (v) => setState(() => _make = v),
                              onLocation: (v) => setState(() => _location = v),
                              onMinYear: (v) => setState(() => _minYear = v),
                              onMaxYear: (v) => setState(() => _maxYear = v),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: 'Search again',
                              icon: Icons.auto_awesome_rounded,
                              loading: _searching,
                              gradient: true,
                              onPressed: _research,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            if (_result.vehicles.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No vehicles matched',
                message:
                    'Try widening the price range, clearing location, or choosing a different model.',
                action: SecondaryButton(
                  label: 'Edit filters',
                  onPressed: () => setState(() => _showRefine = true),
                  expanded: false,
                ),
              )
            else
              ..._result.vehicles.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VehicleCard(vehicle: v),
                ),
              ),
            const SizedBox(height: 12),
            const FeedbackSection(
              title: 'How were these results?',
              subtitle:
                  'Share your feedback to help us improve AI ranking quality.',
              placeholder:
                  'What did you like or dislike about these results?',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _filterChips() {
    final f = _filters;
    final tags = <String>[];
    if (f.make != null) tags.add(f.make!);
    if (f.model != null && f.model!.isNotEmpty) tags.add(f.model!);
    if (f.location != null) tags.add(f.location!);
    if (f.vehicleType.isNotEmpty && f.vehicleType != 'any') {
      tags.add(f.vehicleType);
    }
    if (tags.isEmpty) tags.add('All vehicles');

    return [
      for (var i = 0; i < tags.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: LesiTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(LesiTheme.rSm),
          ),
          child: Text(
            tags[i],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: LesiTheme.inkSoft,
            ),
          ),
        ),
      ],
    ];
  }
}

class _FilterActionChip extends StatelessWidget {
  const _FilterActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: emphasized ? LesiTheme.accentSoft : LesiTheme.surface,
      borderRadius: BorderRadius.circular(LesiTheme.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LesiTheme.rSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LesiTheme.rSm),
            border: Border.all(
              color: emphasized ? LesiTheme.accent : LesiTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: emphasized ? LesiTheme.accent : LesiTheme.inkSoft,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: emphasized ? LesiTheme.accent : LesiTheme.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LesiTheme.surface,
      borderRadius: BorderRadius.circular(LesiTheme.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LesiTheme.rSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LesiTheme.rSm),
            border: Border.all(color: LesiTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: LesiTheme.accent,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.open_in_new_rounded,
                size: 12,
                color: LesiTheme.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
