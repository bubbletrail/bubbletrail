import 'package:btcountries/btcountries.dart';
import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/timezone.dart';
import '../common/units.dart';

// A widget for displaying a dive in a mobile-friendly list layout.
class DiveListItem extends StatelessWidget {
  final Dive dive;
  final Site? site;
  final bool showSite;

  const DiveListItem({super.key, required this.dive, this.site, this.showSite = true});

  DateTime get _startDateTime => dive.start.toDateTime();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxDepth = dive.hasMaxDepth() ? dive.maxDepth : 0.0;
    String? siteLocation;
    if (site != null) {
      final parts = [if (site!.hasLocation()) site!.location, if (site!.hasCountry()) countryDisplayName(site!.country, l10n: context.l10n)];
      if (parts.isNotEmpty) {
        siteLocation = parts.join(', ');
      }
    }

    return InkWell(
      onTap: () {
        context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': dive.id});
      },
      child: Padding(
        padding: const .all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Top row: Dive number, site, and date
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  context.l10n.compactDiveTitle(dive.number, site?.name ?? context.l10n.unknownSite),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
                ),
                DateTimeText(
                  _startDateTime,
                  timezone: siteTimeZone(site),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Middle row: Site location (if shown)
            if (showSite && siteLocation != null) ...[
              _InfoChip(
                icon: Icons.location_on_outlined,
                label: Text(siteLocation, style: theme.textTheme.titleMedium, overflow: .ellipsis),
                theme: theme,
              ),
              const SizedBox(height: 8),
            ],
            // Bottom row: Depth, duration, SAC, rating
            Row(
              spacing: 12,
              children: [
                _InfoChip(icon: Icons.arrow_downward, label: DepthText(maxDepth), theme: theme),
                _InfoChip(icon: Icons.timer_outlined, label: DurationText(dive.duration), theme: theme),
                if (dive.sac > 0)
                  _InfoChip(
                    icon: Icons.speed,
                    label: VolumeText(dive.sac, suffix: context.l10n.perMinute, precise: true),
                    theme: theme,
                  ),
                Expanded(child: Container()),
                _InfoChip(
                  icon: null,
                  label: Text('★' * dive.rating, style: TextStyle(color: theme.colorScheme.primary)),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final Widget label;
  final ThemeData theme;

  const _InfoChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        if (icon != null) Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        label,
      ],
    );
  }
}
