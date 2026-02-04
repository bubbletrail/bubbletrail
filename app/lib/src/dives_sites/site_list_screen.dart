import 'package:btproto/btproto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trina_grid/trina_grid.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import 'dive_list_bloc.dart';
import '../common/common.dart';
import 'site_grouping.dart';
import 'site_list_item_card.dart';

/// Breakpoint width for switching between card (narrow) and table (wide) layouts.
const double _narrowLayoutBreakpoint = 600;

class SiteListScreen extends StatelessWidget {
  const SiteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive Sites'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new dive site', onPressed: () => context.goNamed(AppRouteName.sitesNew))],
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListLoaded) {
            final sites = state.sites;

            if (sites.isEmpty) {
              return const EmptyStateWidget(message: 'No dive sites yet.', icon: Icons.location_on_outlined);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < _narrowLayoutBreakpoint;
                return isNarrow ? _buildCardList(context, sites, state.diveCountBySiteId) : _buildTrinaGrid(context, sites, state.diveCountBySiteId);
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<Site> sites, Map<String, int> diveCountBySiteId) {
    final hierarchy = SiteHierarchy(sites);
    final theme = Theme.of(context);

    return ListView(
      padding: const .symmetric(vertical: 8),
      children: [
        for (final country in hierarchy.countries)
          _CountryExpansionTile(country: country, hierarchy: hierarchy, diveCountBySiteId: diveCountBySiteId, theme: theme),
      ],
    );
  }

  Widget _buildTrinaGrid(BuildContext context, List<Site> sites, Map<String, int> diveCountBySiteId) {
    final columns = <TrinaColumn>[
      TrinaColumn(title: 'Name', field: 'name', type: .text(), width: 200, readOnly: true),
      TrinaColumn(title: 'Country', field: 'country', type: .text(), width: 120, readOnly: true),
      TrinaColumn(title: 'Location', field: 'location', type: .text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Body of water', field: 'bodyOfWater', type: .text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Difficulty', field: 'difficulty', type: .text(), width: 100, readOnly: true),
      TrinaColumn(title: '# Dives', field: 'diveCount', type: .number(), width: 80, readOnly: true),
    ];

    // Sort by country > location > name for logical grouping
    final sortedSites = List<Site>.from(sites)
      ..sort((a, b) {
        final countryCompare = (a.country.isEmpty ? 'zzz' : a.country).compareTo(b.country.isEmpty ? 'zzz' : b.country);
        if (countryCompare != 0) return countryCompare;
        final locationCompare = (a.location.isEmpty ? 'zzz' : a.location).compareTo(b.location.isEmpty ? 'zzz' : b.location);
        if (locationCompare != 0) return locationCompare;
        return a.name.compareTo(b.name);
      });

    final rows = sortedSites.map((site) {
      final diveCount = diveCountBySiteId[site.id] ?? 0;
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: site.name),
          'country': TrinaCell(value: site.country.isEmpty ? '-' : countryDisplayName(site.country)),
          'location': TrinaCell(value: site.location.isEmpty ? '-' : site.location),
          'bodyOfWater': TrinaCell(value: site.bodyOfWater.isEmpty ? '-' : site.bodyOfWater),
          'difficulty': TrinaCell(value: site.difficulty.isEmpty ? '-' : site.difficulty),
          'diveCount': TrinaCell(value: diveCount),
          '_uuid': TrinaCell(value: site.id), // Hidden field for navigation
        },
      );
    }).toList();

    return TrinaGrid(
      key: ValueKey(sites),
      columns: columns,
      rows: rows,
      mode: .selectWithOneTap,
      onRowDoubleTap: (event) {
        final siteId = event.row.cells['_uuid']?.value as String?;
        if (siteId != null) {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': siteId});
        }
      },
      configuration: AppTheme.trinaGridConfiguration(context),
    );
  }
}

class _CountryExpansionTile extends StatefulWidget {
  final String country;
  final SiteHierarchy hierarchy;
  final Map<String, int> diveCountBySiteId;
  final ThemeData theme;

  const _CountryExpansionTile({required this.country, required this.hierarchy, required this.diveCountBySiteId, required this.theme});

  @override
  State<_CountryExpansionTile> createState() => _CountryExpansionTileState();
}

class _CountryExpansionTileState extends State<_CountryExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final locations = widget.hierarchy.locationsFor(widget.country);
    final displayName = SiteHierarchy.countryDisplayNameFor(widget.country);
    final flagAsset = SiteHierarchy.countryFlagAssetFor(widget.country);

    // Calculate aggregate dive count for the country
    int countryDiveCount = 0;
    for (final location in locations) {
      for (final site in widget.hierarchy.sitesFor(widget.country, location)) {
        countryDiveCount += widget.diveCountBySiteId[site.id] ?? 0;
      }
    }

    final children = [
      for (final location in locations)
        _LocationExpansionTile(
          country: widget.country,
          location: location,
          hierarchy: widget.hierarchy,
          diveCountBySiteId: widget.diveCountBySiteId,
          theme: widget.theme,
        ),
    ];

    return ExpansionTile(
      leading: flagAsset != null ? CountryFlag(code: widget.country, size: 32) : const Icon(Icons.public),
      title: Text(displayName, style: const TextStyle(fontWeight: .bold)),
      subtitle: Text('$countryDiveCount ${countryDiveCount == 1 ? 'dive' : 'dives'}', style: widget.theme.textTheme.bodySmall),
      onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
      children: [
        if (_isExpanded && flagAsset != null)
          Stack(
            children: [
              Positioned.fill(child: _TiledFlagBackground(flagAsset: flagAsset)),
              Column(children: children),
            ],
          )
        else
          ...children,
      ],
    );
  }
}

class _TiledFlagBackground extends StatelessWidget {
  final String flagAsset;

  const _TiledFlagBackground({required this.flagAsset});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Opacity(
        opacity: 0.08,
        child: Transform.rotate(
          angle: -0.15, // Slight angle in radians (~8.5 degrees)
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: ImageFiltered(
              imageFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), BlendMode.srcATop),
              child: Wrap(spacing: 20, runSpacing: 20, children: List.generate(50, (_) => Image.asset(flagAsset, width: 80, height: 60, fit: .cover))),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationExpansionTile extends StatelessWidget {
  final String country;
  final String location;
  final SiteHierarchy hierarchy;
  final Map<String, int> diveCountBySiteId;
  final ThemeData theme;

  const _LocationExpansionTile({required this.country, required this.location, required this.hierarchy, required this.diveCountBySiteId, required this.theme});

  @override
  Widget build(BuildContext context) {
    final sites = hierarchy.sitesFor(country, location);
    final displayName = SiteHierarchy.locationDisplayNameFor(location);

    // Calculate aggregate dive count for the location
    int locationDiveCount = 0;
    for (final site in sites) {
      locationDiveCount += diveCountBySiteId[site.id] ?? 0;
    }

    return Padding(
      padding: const .only(left: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.place_outlined, size: 20),
        title: Text(displayName),
        subtitle: Text('$locationDiveCount ${locationDiveCount == 1 ? 'dive' : 'dives'}', style: theme.textTheme.bodySmall),
        children: [
          for (final site in sites)
            Padding(
              padding: const .only(left: 16),
              child: SiteListItemCard(site: site, diveCount: diveCountBySiteId[site.id] ?? 0),
            ),
        ],
      ),
    );
  }
}
