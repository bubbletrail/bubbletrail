import 'package:btproto/btproto.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/units.dart';

/// A card widget for displaying a dive in a mobile-friendly list layout.
class DiveListItemCard extends StatelessWidget {
  final Dive dive;
  final Site? site;
  final bool showSite;

  const DiveListItemCard({super.key, required this.dive, this.site, this.showSite = true});

  DateTime get _startDateTime => dive.start.toDateTime();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxDepth = dive.hasMaxDepth() ? dive.maxDepth : 0.0;
    String? siteName;
    if (site != null) {
      final parts = [if (site!.hasLocation()) site!.location, if (site!.hasCountry()) site!.country];
      if (parts.isNotEmpty) {
        siteName = '${site!.name} (${parts.join(', ')})';
      } else {
        siteName = site!.name;
      }
    }

    return Card(
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': dive.id});
        },
        borderRadius: .circular(12),
        child: Padding(
          padding: const .all(12),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Top row: Dive number and date
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text('Dive #${dive.number}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
                  DateTimeText(_startDateTime, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              // Middle row: Site name (if shown)
              if (showSite && siteName != null) ...[
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(siteName, style: theme.textTheme.bodyMedium, overflow: .ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Bottom row: Depth and duration
              Row(
                children: [
                  _InfoChip(icon: Icons.arrow_downward, label: DepthText(maxDepth), theme: theme),
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.timer, label: DurationText(dive.duration), theme: theme),
                  if (dive.sac > 0) ...[
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.speed,
                      label: VolumeText(dive.sac, suffix: '/min'),
                      theme: theme,
                    ),
                  ],
                  const Spacer(),
                  TimeText(_startDateTime, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Widget label;
  final ThemeData theme;

  const _InfoChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        label,
      ],
    );
  }
}
