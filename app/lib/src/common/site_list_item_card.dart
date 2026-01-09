import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';

/// A card widget for displaying a dive site in a mobile-friendly list layout.
class SiteListItemCard extends StatelessWidget {
  final Site site;
  final int diveCount;

  const SiteListItemCard({super.key, required this.site, required this.diveCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build location subtitle from available fields
    final locationParts = <String>[];
    if (site.location.isNotEmpty) {
      locationParts.add(site.location);
    }
    if (site.country.isNotEmpty) {
      locationParts.add(site.country);
    }
    final locationText = locationParts.isNotEmpty ? locationParts.join(', ') : null;

    return Card(
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': site.id});
        },
        borderRadius: .circular(12),
        child: Padding(
          padding: const .all(12),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Top row: Site name
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.locationDot, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      site.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
                      overflow: .ellipsis,
                    ),
                  ),
                ],
              ),
              // Location subtitle
              if (locationText != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const .only(left: 28),
                  child: Text(
                    locationText,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: .ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Bottom row: Body of water, difficulty, dive count
              Padding(
                padding: const .only(left: 28),
                child: Row(
                  children: [
                    if (site.bodyOfWater.isNotEmpty) ...[_InfoChip(icon: FontAwesomeIcons.water, label: site.bodyOfWater, theme: theme), const SizedBox(width: 12)],
                    if (site.difficulty.isNotEmpty) ...[
                      _InfoChip(icon: FontAwesomeIcons.signal, label: site.difficulty, theme: theme),
                      const SizedBox(width: 12),
                    ],
                    const Spacer(),
                    _InfoChip(icon: FontAwesomeIcons.personSwimming, label: '$diveCount ${diveCount == 1 ? 'dive' : 'dives'}', theme: theme),
                  ],
                ),
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
      mainAxisSize: .min,
      children: [
        FaIcon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
