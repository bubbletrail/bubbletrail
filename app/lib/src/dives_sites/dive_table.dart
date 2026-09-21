import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trina_grid/trina_grid.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../app_theme.dart';
import '../common/common.dart';
import '../preferences/preferences_store.dart';
import 'dive_filters.dart';
import 'dive_list_item_card.dart';
import 'mobile_dive_filter_bar.dart';

const _mobileFilterBarHeight = 64.0;

class DiveTable extends StatefulWidget {
  final List<Dive> dives;
  final Map<String, Site> sitesByUuid;
  final bool showSiteColumn;

  // Whether the card list is the primary scroll view of the screen it
  // appears on, making it the target of scroll-to-top gestures. The
  // embedded table on the site details screen passes false, as it scrolls
  // within another list.
  final bool primary;

  // Shows a collapsible year/country/tag filter bar above the mobile card
  // list. Left off for embedded uses (e.g. the site details screen), where
  // narrowing down by site-level criteria doesn't apply.
  final bool enableFilters;

  const DiveTable({super.key, required this.dives, required this.sitesByUuid, this.showSiteColumn = true, this.primary = true, this.enableFilters = false});

  @override
  State<DiveTable> createState() => _DiveTableState();
}

class _DiveTableState extends State<DiveTable> {
  int? _filterYear;
  String? _filterCountry;
  String? _filterTag;

  void _clearFilters() {
    setState(() {
      _filterYear = null;
      _filterCountry = null;
      _filterTag = null;
    });
  }

  Site? _getSite(Dive dive) {
    if (dive.siteId.isEmpty) return null;
    return widget.sitesByUuid[dive.siteId];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dives.isEmpty) {
      return const Center(child: Text('No dives to display'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < narrowLayoutBreakpoint;
        return isNarrow ? _buildCardList(context) : _buildTrinaGrid(context);
      },
    );
  }

  Widget _buildCardList(BuildContext context) {
    if (!widget.enableFilters) {
      final sortedDives = List<Dive>.from(widget.dives)..sort((a, b) => b.start.toDateTime().compareTo(a.start.toDateTime()));
      return ListView.builder(
        primary: widget.primary,
        padding: const .symmetric(vertical: 8),
        itemCount: sortedDives.length,
        itemBuilder: (context, index) {
          final dive = sortedDives[index];
          return EvenOddContainer(
            index: index,
            child: DiveListItem(dive: dive, site: _getSite(dive), showSite: widget.showSiteColumn),
          );
        },
      );
    }

    final filteredDives = filterDives(widget.dives, widget.sitesByUuid, year: _filterYear, country: _filterCountry, tag: _filterTag)
      ..sort((a, b) => b.start.toDateTime().compareTo(a.start.toDateTime()));

    return CustomScrollView(
      primary: widget.primary,
      slivers: [
        SliverAppBar(
          primary: false,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          floating: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(_mobileFilterBarHeight),
            child: MobileDiveFilterBar(
              selectedYear: _filterYear,
              selectedCountry: _filterCountry,
              selectedTag: _filterTag,
              years: availableDiveYears(widget.dives),
              countries: availableDiveCountries(widget.dives, widget.sitesByUuid),
              tags: availableDiveTags(widget.dives, widget.sitesByUuid).toList()..sort(),
              onYearChanged: (v) => setState(() => _filterYear = v),
              onCountryChanged: (v) => setState(() => _filterCountry = v),
              onTagChanged: (v) => setState(() => _filterTag = v),
            ),
          ),
        ),
        if (filteredDives.isEmpty)
          SliverFillRemaining(
            child: EmptyStateWidget(message: 'No dives match these filters.', actionLabel: 'Clear filters', onAction: _clearFilters),
          )
        else
          SliverList.builder(
            itemCount: filteredDives.length,
            itemBuilder: (context, index) {
              final dive = filteredDives[index];
              return EvenOddContainer(
                index: index,
                child: DiveListItem(dive: dive, site: _getSite(dive), showSite: widget.showSiteColumn),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTrinaGrid(BuildContext context) {
    final prefs = context.watch<PreferencesStore>();
    final columns = <TrinaColumn>[
      TrinaColumn(title: 'Dive #', field: 'number', type: .number(), width: 80, readOnly: true, sort: .descending),
      TrinaColumn(
        title: 'Start',
        field: 'start',
        type: .dateTime(format: prefs.dateTimeFormat),
        width: 170,
        readOnly: true,
      ),
      TrinaColumn(title: 'Max depth', field: 'maxDepth', type: .number(), width: 80, readOnly: true),
      TrinaColumn(title: 'Duration', field: 'duration', type: .number(), width: 80, readOnly: true),
      if (widget.showSiteColumn) TrinaColumn(title: 'Country', field: 'country', type: .text(), width: 120, readOnly: true),
      if (widget.showSiteColumn) TrinaColumn(title: 'Location', field: 'location', type: .text(), width: 120, readOnly: true),
      if (widget.showSiteColumn) TrinaColumn(title: 'Site', field: 'site', type: .text(), width: 120, readOnly: true),
      TrinaColumn(title: 'SAC', field: 'sac', type: .number(), width: 80, readOnly: true),
    ];
    final rows = widget.dives.map((dive) {
      final site = _getSite(dive);
      final siteTz = siteTimeZone(site);
      // Keep the UTC instant as the cell value so sorting stays chronological,
      // and render it in the site's local zone (with zone abbreviation).
      final startUtc = dive.start.toDateTime();
      return TrinaRow(
        cells: {
          'number': TrinaCell(value: dive.number),
          // The dateTime column keeps the DateTime value for sorting; the
          // renderer captures the instant directly (the cell's own value is
          // normalised to a formatted string by the column type).
          'start': TrinaCell(
            value: startUtc,
            renderer: (_) => DateTimeText(startUtc, timezone: siteTz),
          ),
          'maxDepth': TrinaCell(value: dive.maxDepth * 10, renderer: (rendererContext) => DepthText(rendererContext.cell.value / 10)),
          'duration': TrinaCell(value: dive.duration, renderer: (rendererContext) => DurationText(rendererContext.cell.value)),
          'country': TrinaCell(value: countryDisplayName(site?.country ?? '')),
          'location': TrinaCell(value: site?.location ?? ''),
          'site': TrinaCell(value: site?.name ?? ''),
          'sac': TrinaCell(
            value: dive.sac * 10,
            renderer: (rendererContext) => rendererContext.cell.value != 0 ? VolumeText(rendererContext.cell.value / 10, suffix: '/min') : Text('-'),
          ),
          '_id': TrinaCell(value: dive.id), // Hidden field for navigation
        },
      );
    }).toList();
    return TrinaGrid(
      key: ValueKey((prefs.dateTimeFormat, widget.dives)), // ensure reload when date format change
      columns: columns,
      rows: rows,
      mode: .selectWithOneTap,
      onRowDoubleTap: (event) {
        final diveId = event.row.cells['_id']?.value as String?;
        if (diveId != null) {
          context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': diveId});
        }
      },
      configuration: AppTheme.trinaGridConfiguration(context),
    );
  }
}
