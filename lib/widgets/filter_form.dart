import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../theme/lesi_theme.dart';
import 'common.dart';

/// Progressive filter form: chips for type, clean dropdowns, collapsible extras.
class SearchFilterForm extends StatelessWidget {
  const SearchFilterForm({
    super.key,
    required this.vehicleType,
    required this.make,
    required this.modelController,
    required this.location,
    required this.minYear,
    required this.maxYear,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onVehicleType,
    required this.onMake,
    required this.onLocation,
    required this.onMinYear,
    required this.onMaxYear,
    this.showMoreFilters = true,
    this.moreFiltersOpen = false,
    this.onToggleMore,
  });

  final String vehicleType;
  final String make;
  final TextEditingController modelController;
  final String location;
  final int? minYear;
  final int? maxYear;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final ValueChanged<String> onVehicleType;
  final ValueChanged<String> onMake;
  final ValueChanged<String> onLocation;
  final ValueChanged<int?> onMinYear;
  final ValueChanged<int?> onMaxYear;
  final bool showMoreFilters;
  final bool moreFiltersOpen;
  final VoidCallback? onToggleMore;

  SearchFilters toFilters({int maxPages = 3}) {
    return SearchFilters(
      make: make.isEmpty ? null : make,
      model: modelController.text,
      location: location.isEmpty ? null : location,
      vehicleType: vehicleType.isEmpty ? 'any' : vehicleType,
      minPrice: int.tryParse(minPriceController.text.replaceAll(',', '')),
      maxPrice: int.tryParse(maxPriceController.text.replaceAll(',', '')),
      minYear: minYear,
      maxYear: maxYear,
      maxPages: maxPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = AppConfig.yearChoices();
    final types = AppConfig.vehicleTypes
        .where((t) => t.value.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('Type'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: types.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _TypeChip(
                  label: 'Any type',
                  selected: vehicleType.isEmpty,
                  onTap: () => onVehicleType(''),
                );
              }
              final t = types[index - 1];
              return _TypeChip(
                label: t.label,
                selected: vehicleType == t.value,
                onTap: () => onVehicleType(t.value),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const FieldLabel('Make'),
        DropdownButtonFormField<String>(
          key: ValueKey('make-$make'),
          initialValue: make,
          decoration: const InputDecoration(hintText: 'Any make'),
          items: [
            const DropdownMenuItem(value: '', child: Text('Any make')),
            ...AppConfig.makes.map(
              (m) => DropdownMenuItem(value: m, child: Text(m)),
            ),
          ],
          onChanged: (v) => onMake(v ?? ''),
        ),
        const SizedBox(height: 16),
        const FieldLabel('Model'),
        TextField(
          controller: modelController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'e.g. aqua, axio'),
        ),
        if (showMoreFilters) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: onToggleMore,
            borderRadius: BorderRadius.circular(LesiTheme.rSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    moreFiltersOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.expand_more_rounded,
                    color: LesiTheme.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'More filters',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: LesiTheme.accent,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Location, year & price',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const FieldLabel('Location'),
                DropdownButtonFormField<String>(
                  key: ValueKey('loc-$location'),
                  initialValue: location,
                  decoration: const InputDecoration(hintText: 'Any location'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Any location'),
                    ),
                    for (final group in AppConfig.locations)
                      ...group.places.map(
                        (p) => DropdownMenuItem(value: p, child: Text(p)),
                      ),
                  ],
                  onChanged: (v) => onLocation(v ?? ''),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FieldLabel('Min Year'),
                          DropdownButtonFormField<int?>(
                            key: ValueKey('miny-$minYear'),
                            initialValue: minYear,
                            decoration:
                                const InputDecoration(hintText: 'Any'),
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
                            onChanged: onMinYear,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FieldLabel('Max Year'),
                          DropdownButtonFormField<int?>(
                            key: ValueKey('maxy-$maxYear'),
                            initialValue: maxYear,
                            decoration:
                                const InputDecoration(hintText: 'Any'),
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
                            onChanged: onMaxYear,
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
                          const FieldLabel('Min Price (LKR)'),
                          TextField(
                            controller: minPriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 7,500,000',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FieldLabel('Max Price (LKR)'),
                          TextField(
                            controller: maxPriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 8,200,000',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: moreFiltersOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? LesiTheme.accent : LesiTheme.surfaceMuted,
      borderRadius: BorderRadius.circular(LesiTheme.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LesiTheme.rSm),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : LesiTheme.inkSoft,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
