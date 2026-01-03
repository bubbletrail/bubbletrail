import 'package:divestore/divestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../common/units.dart';
import '../preferences/preferences.dart';

class DepthProfileWidget extends StatelessWidget {
  final Log log;

  const DepthProfileWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    // Filter out samples without depth data
    final samplesWithDepth = log.samples.where((s) => s.hasDepth()).toList();
    final lastNonZeroIdx = samplesWithDepth.lastIndexWhere((s) => s.depth != 0);
    if (lastNonZeroIdx < samplesWithDepth.length - 2) {
      // Trim tail of zero samples
      samplesWithDepth.removeRange(lastNonZeroIdx + 2, samplesWithDepth.length);
    }

    final prefs = context.watch<PreferencesBloc>().state.preferences;
    final depthUnit = prefs.depthUnit;
    final tempUnit = prefs.temperatureUnit;
    final pressureUnit = prefs.pressureUnit;
    final depthMult = depthUnit == DepthUnit.feet ? 3.28 : 1.0;

    if (samplesWithDepth.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('No depth profile data available')),
      );
    }

    // Depth data
    final maxDepth = depthMult * -samplesWithDepth.map((s) => s.depth).reduce((a, b) => a > b ? a : b);
    final chartMaxDepth = ((maxDepth ~/ 3) - 1).toDouble() * 3;
    final maxTime = samplesWithDepth.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    final depthSpots = samplesWithDepth.map((sample) => FlSpot(sample.time / 60, depthMult * -sample.depth)).toList();

    // Temperature data - normalize to depth range, step-style
    final samplesWithTemp = samplesWithDepth.where((s) => s.hasTemperature() && s.temperature != 0).toList();
    List<FlSpot> tempSpots = [];
    double minTemp = 0, maxTemp = 0;
    if (samplesWithTemp.isNotEmpty) {
      minTemp = samplesWithTemp.map((s) => s.temperature).reduce((a, b) => a < b ? a : b);
      maxTemp = samplesWithTemp.map((s) => s.temperature).reduce((a, b) => a > b ? a : b);
      final tempRange = maxTemp - minTemp;
      if (tempRange > 0) {
        double normalizeTemp(double temp) {
          final normalized = (temp - minTemp) / tempRange;
          return maxDepth * 0.9 - normalized * (maxDepth * 0.2);
        }

        tempSpots = _buildStepSpots(samplesWithTemp, (s) => s.time / 60, (s) => normalizeTemp(s.temperature), maxTime);
      }
    }

    // Pressure data - find all tank indices used
    final tankIndices = <int>{};
    for (final sample in samplesWithDepth) {
      for (final p in sample.pressures) {
        if (p.pressure > 0) tankIndices.add(p.tankIndex);
      }
    }

    // Build pressure spots for each tank, normalized to depth range, step-style
    final pressureData = <int, ({List<FlSpot> spots, double minPressure, double maxPressure})>{};
    for (final tankIndex in tankIndices) {
      final samplesWithPressure = samplesWithDepth.where((s) => s.pressures.any((p) => p.tankIndex == tankIndex && p.pressure > 0)).toList();
      if (samplesWithPressure.isEmpty) continue;

      final pressures = samplesWithPressure.map((s) => s.pressures.firstWhere((p) => p.tankIndex == tankIndex).pressure).toList();
      final minPressure = pressures.reduce((a, b) => a < b ? a : b);
      final maxPressure = pressures.reduce((a, b) => a > b ? a : b);
      final pressureRange = maxPressure - minPressure;

      if (pressureRange > 0) {
        double normalizePressure(double pressure) {
          final normalized = pressure / maxPressure;
          return maxDepth * 0.9 - normalized * (maxDepth * 0.8);
        }

        final spots = _buildStepSpots(
          samplesWithPressure,
          (s) => s.time / 60,
          (s) => normalizePressure(s.pressures.firstWhere((p) => p.tankIndex == tankIndex).pressure),
          maxTime,
        );
        pressureData[tankIndex] = (spots: spots, minPressure: minPressure, maxPressure: maxPressure);
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final borderColor = colorScheme.outline;
    final tempColor = Colors.orange;
    final pressureColors = [Colors.teal, Colors.cyan, Colors.green, Colors.lime];

    // Build line bars
    final lineBars = <LineChartBarData>[
      // Depth line (main)
      LineChartBarData(
        spots: depthSpots,
        color: primaryColor,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        aboveBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.3)),
      ),
    ];

    // Temperature line
    if (tempSpots.isNotEmpty) {
      lineBars.add(LineChartBarData(spots: tempSpots, color: tempColor, barWidth: 1, dotData: const FlDotData(show: false), dashArray: [4, 2]));
    }

    // Pressure lines
    var pressureColorIdx = 0;
    for (final entry in pressureData.entries) {
      lineBars.add(
        LineChartBarData(
          spots: entry.value.spots,
          color: pressureColors[pressureColorIdx % pressureColors.length],
          barWidth: 1,
          dotData: const FlDotData(show: false),
          dashArray: [2, 2],
        ),
      );
      pressureColorIdx++;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text('Depth (${depthUnit.label})'),
                sideTitles: SideTitles(
                  showTitles: true,
                  minIncluded: false,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(value.toStringAsFixed(0).replaceFirst('-', ''), style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                axisNameWidget: const Text('Time (min)'),
                sideTitles: SideTitles(
                  showTitles: true,
                  maxIncluded: false,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: borderColor)),
            minX: 0,
            maxX: maxTime + 0.5, // minutes
            minY: chartMaxDepth,
            maxY: 0,
            lineBarsData: lineBars,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                  if (spot.barIndex != 0) return null;

                  // Find the time from the spot with line bar index zero, the depth line.
                  final time = touchedSpots.firstWhere((s) => s.barIndex == 0).x;
                  final timeSeconds = (time * 60).toInt();

                  // Find the sample closest to this time
                  final sample = _findClosestSample(samplesWithDepth, timeSeconds);
                  if (sample == null) return null;

                  // Build tooltip text
                  final lines = <String>[];
                  lines.add(formatDuration(sample.time.toInt()));
                  lines.add(formatDepth(depthUnit, sample.depth));

                  if (sample.hasTemperature() && sample.temperature != 0) {
                    lines.add(formatTemperature(tempUnit, sample.temperature));
                  }

                  for (final p in sample.pressures) {
                    if (p.pressure > 0) {
                      final tankLabel = sample.pressures.length > 1 ? 'T${p.tankIndex + 1}: ' : '';
                      lines.add('$tankLabel${formatPressure(pressureUnit, p.pressure)}');
                    }
                  }

                  return LineTooltipItem(
                    lines.join('\n'),
                    TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  );
                }).toList(),
                showOnTopOfTheChartBoxArea: true,
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((idx) {
                if (barData.barWidth < 2) return null; // hack to identify depth line
                return TouchedSpotIndicatorData(FlLine(color: Theme.of(context).colorScheme.secondary, strokeWidth: 1), FlDotData());
              }).toList(),
              getTouchLineStart: (barData, spotIndex) => 0,
              getTouchLineEnd: (barData, spotIndex) => chartMaxDepth,
            ),
          ),
        ),
      ),
    );
  }

  LogSample? _findClosestSample(List<LogSample> samples, int timeSeconds) {
    if (samples.isEmpty) return null;
    final res = LogSample();
    for (final sample in samples) {
      if (sample.time > timeSeconds) return res;
      res.time = sample.time;
      if (sample.hasDepth()) res.depth = sample.depth;
      if (sample.hasTemperature()) res.temperature = sample.temperature;
      if (sample.pressures.isNotEmpty) {
        res.pressures
          ..clear()
          ..addAll(sample.pressures);
      }
    }
    return res;
  }

  /// Builds step-style graph spots from samples.
  /// For each pair of consecutive samples, adds a synthetic point just before
  /// the second sample at the first sample's Y value to create a step effect.
  /// Extends the last value to maxTime if there's a gap.
  /// Optimization: skips synthetic points when samples are close together
  /// (less than 4 samples apart) as the step wouldn't be visible anyway.
  List<FlSpot> _buildStepSpots(List<LogSample> samples, double Function(LogSample) getX, double Function(LogSample) getY, double maxTime) {
    if (samples.isEmpty) return [];
    if (samples.length == 1) {
      final x = getX(samples.first);
      final y = getY(samples.first);
      // Extend single point to end of dive
      if (maxTime > x) {
        return [FlSpot(x, y), FlSpot(maxTime, y)];
      }
      return [FlSpot(x, y)];
    }

    final spots = <FlSpot>[];
    const minSampleGap = 4; // Don't add synthetic points if gap is smaller than this

    for (var i = 0; i < samples.length; i++) {
      final sample = samples[i];
      final x = getX(sample);
      final y = getY(sample);

      // Add the actual sample point
      spots.add(FlSpot(x, y));

      // If there's a next sample, potentially add a synthetic step point
      if (i < samples.length - 1) {
        final nextSample = samples[i + 1];
        final nextX = getX(nextSample);

        // Calculate time gap in terms of approximate sample count
        // Assuming ~1 sample per second on average
        final timeGap = nextSample.time - sample.time;

        // Only add synthetic point if gap is large enough to be visible
        if (timeGap >= minSampleGap) {
          // Add synthetic point just before the next sample, at current Y
          final syntheticX = nextX - 0.01; // Tiny offset before next point
          spots.add(FlSpot(syntheticX, y));
        }
      }
    }

    // Extend the last value to the end of the dive
    final lastY = getY(samples.last);
    final lastX = getX(samples.last);
    if (maxTime > lastX) {
      spots.add(FlSpot(maxTime, lastY));
    }

    return spots;
  }
}
