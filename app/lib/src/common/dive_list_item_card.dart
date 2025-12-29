import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_routes.dart';
import 'units.dart';

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

    return Card(
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': dive.id});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Dive number and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dive #${dive.number}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(DateFormat.yMd().format(_startDateTime), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              // Middle row: Site name (if shown)
              if (showSite && site != null) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(site!.name, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Bottom row: Depth and duration
              Row(
                children: [
                  _InfoChip(icon: Icons.arrow_downward, label: formatDepth(context, maxDepth), theme: theme),
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.timer, label: formatDuration(dive.duration), theme: theme),
                  const Spacer(),
                  Text(DateFormat.jm().format(_startDateTime), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
  final String label;
  final ThemeData theme;

  const _InfoChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
