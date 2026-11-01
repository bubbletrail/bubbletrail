import 'dart:math';

import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_routes.dart';
import '../common/common.dart';
import '../dives_sites/dive_list_bloc.dart';
import '../preferences/preferences_store.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.statistics),
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListLoaded) {
            if (state.dives.isEmpty) {
              return EmptyStateWidget(message: context.l10n.noDivesYetAddYourFirstDiveToSeeStatistics, icon: Icons.insights_outlined);
            }
            return _Statistics(dives: state.dives);
          }

          return Center(child: Text(context.l10n.unknownState));
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
            title: context.l10n.activity,
            even: index % 2 == 0,
            children: [_DiveHeatMap(dives: dives)],
          );
        }
        if (index == 1) {
          return InfoSection(
            title: context.l10n.lifetime,
            even: index % 2 == 0,
            children: [infoRow(context.l10n.yearsDiving, years.length.toString()), ..._statRows(context, prefs, lifetime)],
          );
        }
        final (year, stats) = years[index - 2];
        return InfoSection(title: year.toString(), even: index % 2 == 0, children: _statRows(context, prefs, stats));
      },
    );
  }

  List<Widget> _statRows(BuildContext context, PreferencesStore prefs, _Stats stats) {
    return [
      infoRow(context.l10n.dives, stats.count.toString()),
      infoRow(context.l10n.totalTime, formatTotalTime(context.l10n, stats.totalSeconds)),
      infoRow(context.l10n.averageMaxDepth, formatDepth(context.l10n, prefs.depthUnit, stats.avgMaxDepth)),
      if (stats.hasDeepest)
        _diveRow(context, context.l10n.deepestDive, Text(formatDepth(context.l10n, prefs.depthUnit, stats.maxMaxDepth)), stats.deepestDive!),
      if (stats.hasLongest) _diveRow(context, context.l10n.longestDive, DurationText(stats.longestSeconds), stats.longestDive!),
      if (stats.hasWarmest)
        _diveRow(context, context.l10n.warmestDive, Text(formatTemperature(context.l10n, prefs.temperatureUnit, stats.warmestTemp)), stats.warmestDive!),
      if (stats.hasColdest)
        _diveRow(context, context.l10n.coldestDive, Text(formatTemperature(context.l10n, prefs.temperatureUnit, stats.coldestTemp)), stats.coldestDive!),
      if (stats.hasSAC)
        infoRow(context.l10n.averageSAC, context.l10n.ratePerMinute(formatVolume(context.l10n, prefs.volumeUnit, stats.averageSAC, precise: true))),
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
    if (dive.hasSac()) {
      stats.sacTimesDuration += dive.sac * dive.duration;
      stats.sacTotalDuration += dive.duration;
    }
  }
}

// Like formatMinutes, but extends to hours and days: "95 min", "120 min",
// "2 hours, 1 min", "2 days, 3 hours", "14 days, 2 hours, 5 min".
String formatTotalTime(AppLocalizations l10n, int seconds) {
  final totalMinutes = (seconds / 60).round();
  if (totalMinutes <= 120) return l10n.minutesDuration(totalMinutes);
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours <= 48) return l10n.hoursMinutesDuration(hours, minutes);
  final days = hours ~/ 24;
  final restHours = hours % 24;
  if (minutes == 0) return l10n.daysHoursDuration(days, restHours);
  return l10n.daysHoursMinutesDuration(days, restHours, minutes);
}

// Dive activity heat map, contribution graph style: one row per year (latest
// year first) and one square per month, colored by dive count along the
// primary color scale. Months without dives are left blank.
class _DiveHeatMap extends StatelessWidget {
  final List<Dive> dives;

  const _DiveHeatMap({required this.dives});

  @override
  Widget build(BuildContext context) {
    final monthNames = DateFormat.MMM(context.l10n.localeName).dateSymbols.SHORTMONTHS;
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
          final intensity = count / maxCount;
          final color = Color.lerp(cs.primaryContainer, cs.primary, intensity)!;
          return SizedBox(
            width: cell,
            height: cell,
            child: Padding(
              padding: const .all(2.0),
              child: Tooltip(
                message: context.l10n.monthlyDiveCount(monthNames[month], year, count),
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
                        child: Text(monthNames[m], style: labelStyle),
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

  double sacTimesDuration = 0;
  double sacTotalDuration = 0;

  double get avgMaxDepth => maxDepthCount > 0 ? maxDepthSum / maxDepthCount : 0;
  bool get hasSAC => sacTotalDuration > 0;
  double get averageSAC => sacTimesDuration / sacTotalDuration;
}
