import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/in_app_browser_screen.dart';
import '../theme/lesi_theme.dart';
import 'remote_image.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle});

  final RankedVehicle vehicle;

  Future<void> _open(BuildContext context) async {
    final raw = vehicle.url;
    if (raw == null || raw.isEmpty) return;
    await openInAppBrowser(
      context,
      url: raw,
      title: vehicle.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rank = vehicle.rank;
    final (Color tone, String? badge) = switch (rank) {
      1 => (LesiTheme.gold, 'Best pick'),
      2 => (LesiTheme.silver, 'Runner-up'),
      3 => (LesiTheme.bronze, 'Top 3'),
      _ => (LesiTheme.accent, null),
    };

    final name = (vehicle.name ?? 'Untitled listing')
        .replaceAll('(used)', '')
        .replaceAll('(Used)', '')
        .trim();

    final thumb = RemoteImage.normalizeUrl(vehicle.thumbnailUrl);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: LesiTheme.surface,
      borderRadius: BorderRadius.circular(LesiTheme.rMd),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(LesiTheme.rMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LesiTheme.rMd),
            border: Border.all(color: LesiTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(LesiTheme.rMd - 1),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumb != null)
                        RemoteImage(
                          url: thumb,
                          fit: BoxFit.cover,
                          placeholder:
                              Container(color: LesiTheme.surfaceMuted),
                          error: _placeholder(),
                        )
                      else
                        _placeholder(),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: LesiTheme.ink.withValues(alpha: 0.78),
                            borderRadius:
                                BorderRadius.circular(LesiTheme.rSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  badge,
                                  style: TextStyle(
                                    color: tone,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (vehicle.source != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius:
                                  BorderRadius.circular(LesiTheme.rSm),
                            ),
                            child: Text(
                              vehicle.source!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: LesiTheme.inkSoft,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vehicle.priceLabel,
                      style: textTheme.titleMedium?.copyWith(
                        color: LesiTheme.accentDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (vehicle.year != null) _meta('${vehicle.year}'),
                        if (vehicle.location != null) _meta(vehicle.location!),
                        if (vehicle.mileage != null)
                          _meta('${vehicle.mileage} km'),
                        if (vehicle.fuelType != null) _meta(vehicle.fuelType!),
                        if (vehicle.gear != null) _meta(vehicle.gear!),
                      ],
                    ),
                    if (vehicle.details != null &&
                        vehicle.details.toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        vehicle.details.toString().length > 120
                            ? '${vehicle.details.toString().substring(0, 120)}…'
                            : vehicle.details.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'View listing',
                          style: textTheme.titleSmall?.copyWith(
                            color: LesiTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          size: 15,
                          color: LesiTheme.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: LesiTheme.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 36,
          color: LesiTheme.muted,
        ),
      ),
    );
  }

  Widget _meta(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LesiTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(LesiTheme.rSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: LesiTheme.inkSoft,
        ),
      ),
    );
  }
}
