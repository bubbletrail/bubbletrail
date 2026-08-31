import 'dart:math';

import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../common/common.dart';
import '../preferences/preferences_store.dart';
import '../app_routes.dart';
import '../dives_sites/dive_list_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Statistics'),
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListLoaded) {
            if (state.dives.isEmpty) {
              return const EmptyStateWidget(message: 'No dives yet. Add your first dive to see statistics!', icon: Icons.insights_outlined);
            }
            return _Statistics(dives: state.dives);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class _Statistics extends StatelessWidget {
  final List<Dive> dives;

  const _Statistics({required this.dives});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesStore>();

    final years = _statsByYear();
    final lifetime = _lifetimeStats();

    return ListView.builder(
      itemCount: years.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InfoSection(
            title: 'Activity',
            even: index % 2 == 0,
            children: [_DiveHeatMap(dives: dives)],
          );
        }
        if (index == 1) {
          return InfoSection(
            title: 'Lifetime',
            even: index % 2 == 0,
            children: [infoRow('Years diving', '${years.length}'), ..._statRows(context, prefs, lifetime)],
          );
        }
        final (year, stats) = years[index - 2];
        return InfoSection(title: year.toString(), even: index % 2 == 0, children: _statRows(context, prefs, stats));
      },
    );
  }

  List<Widget> _statRows(BuildContext context, PreferencesStore prefs, _Stats stats) {
    return [
      infoRow('Dives', '${stats.count}'),
      infoRow('Total time', _formatTotalTime(stats.totalSeconds)),
      infoRow('Average max depth', formatDepth(prefs.depthUnit, stats.avgMaxDepth)),
      if (stats.hasDeepest) _diveRow(context, 'Deepest dive', Text(formatDepth(prefs.depthUnit, stats.maxMaxDepth)), stats.deepestDive!),
      if (stats.hasLongest) _diveRow(context, 'Longest dive', DurationText(stats.longestSeconds), stats.longestDive!),
      if (stats.hasWarmest) _diveRow(context, 'Warmest dive', Text(formatTemperature(prefs.temperatureUnit, stats.warmestTemp)), stats.warmestDive!),
      if (stats.hasColdest) _diveRow(context, 'Coldest dive', Text(formatTemperature(prefs.temperatureUnit, stats.coldestTemp)), stats.coldestDive!),
    ];
  }

  Widget _diveRow(BuildContext context, String label, Widget value, Dive dive) {
    return infoWidgetRow(
      label,
      InkWell(
        onTap: () => context.pushNamed(AppRouteName.divesDetails, pathParameters: {'diveID': dive.id}),
        child: DefaultTextStyle(
          style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
          child: value,
        ),
      ),
    );
  }

  List<(int, _Stats)> _statsByYear() {
    final stats = <int, _Stats>{};
    for (final dive in dives) {
      if (!dive.hasStart()) continue;
      final year = dive.start.toDateTime().year;
      _accumulate(stats.putIfAbsent(year, _Stats.new), dive);
    }
    final years = stats.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) => b.$1.compareTo(a.$1));
    return years;
  }

  _Stats _lifetimeStats() {
    final stats = _Stats();
    for (final dive in dives) {
      _accumulate(stats, dive);
    }
    return stats;
  }

  void _accumulate(_Stats stats, Dive dive) {
    stats.count++;
    stats.totalSeconds += dive.duration;
    if (dive.hasMaxDepth()) {
      stats.maxDepthSum += dive.maxDepth;
      stats.maxDepthCount++;
      if (!stats.hasDeepest || dive.maxDepth > stats.maxMaxDepth) {
        stats.maxMaxDepth = dive.maxDepth;
        stats.deepestDive = dive;
        stats.hasDeepest = true;
      }
    }
    if (!stats.hasLongest || dive.duration > stats.longestSeconds) {
      stats.longestSeconds = dive.duration;
      stats.longestDive = dive;
      stats.hasLongest = true;
    }
    if (dive.hasMaxTemp()) {
      final temp = dive.maxTemp;
      if (!stats.hasWarmest || temp > stats.warmestTemp) {
        stats.warmestTemp = temp;
        stats.warmestDive = dive;
        stats.hasWarmest = true;
      }
    }
    if (dive.hasMinTemp()) {
      final temp = dive.minTemp;
      if (!stats.hasColdest || temp < stats.coldestTemp) {
        stats.coldestTemp = temp;
        stats.coldestDive = dive;
        stats.hasColdest = true;
      }
    }
  }
}

// Like formatMinutes, but extends to hours and days: "95 min", "120 min",
// "2 hours, 1 min", "2 days, 3 hours", "14 days, 2 hours, 5 min".
String _formatTotalTime(int seconds) {
  final totalMinutes = (seconds / 60).round();
  if (totalMinutes <= 120) return '$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours <= 48) return '$hours hours, $minutes min';
  final days = hours ~/ 24;
  final restHours = hours % 24;
  if (minutes == 0) return '$days days, $restHours hours';
  return '$days days, $restHours hours, $minutes min';
}

// Months of the year, index zero being January.
const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// Dive activity heat map, contribution graph style: one row per year (latest
// year first) and one square per month, colored by dive count along the
// primary color scale. Months without dives are left blank.
class _DiveHeatMap extends StatelessWidget {
  final List<Dive> dives;

  const _DiveHeatMap({required this.dives});

  @override
  Widget build(BuildContext context) {
    final counts = <int, List<int>>{};
    for (final dive in dives) {
      if (!dive.hasStart()) continue;
      final dt = dive.start.toDateTime();
      counts.putIfAbsent(dt.year, () => List.filled(12, 0))[dt.month - 1]++;
    }
    if (counts.isEmpty) return const SizedBox.shrink();
    final years = counts.keys.toList()..sort((a, b) => b.compareTo(a));
    final maxCount = counts.values.expand((months) => months).reduce(max);

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        const yearWidth = 36.0;
        final cell = min((constraints.maxWidth - yearWidth) / 12, 24.0);
        final labelStyle = theme.textTheme.labelSmall;

        Widget slot(int year, int month) {
          final count = counts[year]![month];
          if (count == 0) {
            return SizedBox(width: cell, height: cell);
          }
          // Square root scaling, so a couple of dives in an otherwise quiet
          // log still get a clearly visible tint.
          final intensity = sqrt(count / maxCount);
          final color = Color.lerp(cs.primaryContainer, cs.primary, intensity)!;
          return SizedBox(
            width: cell,
            height: cell,
            child: Padding(
              padding: const .all(2.0),
              child: Tooltip(
                message: '${_monthNames[month]} $year: ${count == 1 ? '1 dive' : '$count dives'}',
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                const SizedBox(width: yearWidth),
                for (var m = 0; m < 12; m++)
                  SizedBox(
                    width: cell,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_monthNames[m], style: labelStyle),
                      ),
                    ),
                  ),
              ],
            ),
            for (final year in years)
              Padding(
                padding: const .symmetric(vertical: 1.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: yearWidth,
                      child: Text('$year', style: labelStyle),
                    ),
                    for (var m = 0; m < 12; m++) slot(year, m),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Stats {
  int count = 0;
  int totalSeconds = 0;
  double maxDepthSum = 0;
  int maxDepthCount = 0;
  bool hasDeepest = false;
  double maxMaxDepth = 0;
  Dive? deepestDive;
  bool hasLongest = false;
  int longestSeconds = 0;
  Dive? longestDive;
  bool hasWarmest = false;
  double warmestTemp = 0;
  Dive? warmestDive;
  bool hasColdest = false;
  double coldestTemp = 0;
  Dive? coldestDive;

  double get avgMaxDepth => maxDepthCount > 0 ? maxDepthSum / maxDepthCount : 0;
}
