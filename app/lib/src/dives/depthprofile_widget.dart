import 'package:divestore/divestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../preferences/preferences.dart';

class DepthProfileWidget extends StatefulWidget {
  final Log log;
  final Preferences preferences;

  const DepthProfileWidget({super.key, required this.log, required this.preferences});

  @override
  State<DepthProfileWidget> createState() => _DepthProfileWidgetState();
}

class _DepthProfileWidgetState extends State<DepthProfileWidget> {
  LogSample? _displaySample;
  double _maxTime = 0;
  double _chartMaxDepth = 0;
  final List<FlSpot> _tempSpots = [];
  final List<LogSample> samplesWithDepth = [];
  final List<FlSpot> _depthSpots = [];
  final List<FlSpot> _ceilingSpots = [];
  final _pressureData = <int, ({List<FlSpot> spots, double minPressure, double maxPressure})>{};

  @override
  void initState() {
    super.initState();

    // Filter out samples without depth data
    samplesWithDepth.addAll(widget.log.samples.where((s) => s.hasDepth()));
    final lastNonZeroIdx = samplesWithDepth.lastIndexWhere((s) => s.depth != 0);
    if (lastNonZeroIdx < samplesWithDepth.length - 2) {
      // Trim tail of zero samples
      samplesWithDepth.removeRange(lastNonZeroIdx + 2, samplesWithDepth.length);
    }

    final depthUnit = widget.preferences.depthUnit;
    final depthMult = depthUnit == DepthUnit.feet ? 3.28 : 1.0;

    // Depth data
    final maxDepth = depthMult * -samplesWithDepth.map((s) => s.depth).reduce((a, b) => a > b ? a : b);
    _chartMaxDepth = ((maxDepth ~/ 3) - 1).toDouble() * 3;
    _maxTime = samplesWithDepth.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    _depthSpots.addAll(samplesWithDepth.map((sample) => FlSpot(sample.time / 60, depthMult * -sample.depth)));

    // Temperature data - normalize to depth range, step-style
    final samplesWithTemp = samplesWithDepth.where((s) => s.hasTemperature() && s.temperature != 0).toList();
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

        _tempSpots.addAll(_buildStepSpots(samplesWithTemp, (s) => s.time / 60, (s) => normalizeTemp(s.temperature), _maxTime));
      }
    }

    // Deco ceiling
    for (final sample in samplesWithDepth) {
      final hasCeiling = sample.deco.type == DecoStopType.DECO_STOP_TYPE_DECO_STOP && sample.deco.depth > 0;
      final ceilingDepth = hasCeiling ? sample.deco.depth : -1.0;
      _ceilingSpots.add(FlSpot(sample.time / 60, depthMult * -ceilingDepth));
    }

    // Pressure data - find all tank indices used
    final tankIndices = <int>{};
    for (final sample in samplesWithDepth) {
      for (final p in sample.pressures) {
        if (p.pressure > 0) tankIndices.add(p.tankIndex);
      }
    }

    // Build pressure spots for each tank, normalized to depth range, step-style
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
          _maxTime,
        );
        _pressureData[tankIndex] = (spots: spots, minPressure: minPressure, maxPressure: maxPressure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (samplesWithDepth.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('No depth profile data available')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final borderColor = colorScheme.outline;
    final tempColor = Colors.orange;
    final pressureColors = [Colors.teal, Colors.cyan, Colors.green, Colors.lime];
    final ceilingColor = Colors.red;

    // Build line bars
    final lineBars = <LineChartBarData>[];

    // Deco ceiling
    if (_ceilingSpots.isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: _ceilingSpots,
          color: ceilingColor,
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          aboveBarData: BarAreaData(show: true, color: ceilingColor.withValues(alpha: 0.5), cutOffY: 0, applyCutOffY: true),
        ),
      );
    }

    // Depth line (main) - track its index for touch handling
    final depthLineIndex = lineBars.length;
    lineBars.add(
      LineChartBarData(
        spots: _depthSpots,
        color: primaryColor,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        aboveBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.3)),
      ),
    );

    // Temperature line
    if (_tempSpots.isNotEmpty) {
      lineBars.add(LineChartBarData(spots: _tempSpots, color: tempColor, barWidth: 1, dotData: const FlDotData(show: false), dashArray: [4, 2]));
    }

    // Pressure lines
    var pressureColorIdx = 0;
    for (final entry in _pressureData.entries) {
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

    return Stack(
      children: [
        // Top info line
        if (_displaySample != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 48),
            child: Row(
              spacing: 16,
              children: [
                Text(formatDuration(_displaySample!.time.toInt())),
                DepthText(_displaySample!.depth),
                TemperatureText(_displaySample!.temperature),
                if (_displaySample!.pressures.isNotEmpty) PressureText(_displaySample!.pressures.first.pressure),
                if (_displaySample!.hasDeco() && _displaySample!.deco.depth > 0) DepthText(_displaySample!.deco.depth, prefix: 'Ceil: '),
              ],
            ),
          ),

        // Chart
        LineChart(
          LineChartData(
            backgroundColor: Colors.transparent,
            gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  minIncluded: false,
                  reservedSize: 24,
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
                sideTitles: SideTitles(
                  showTitles: true,
                  maxIncluded: false,
                  reservedSize: 16,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: borderColor)),
            minX: 0,
            maxX: _maxTime + 0.5, // minutes
            minY: _chartMaxDepth,
            maxY: 0,
            lineBarsData: lineBars,
            lineTouchData: LineTouchData(
              touchCallback: (event, resp) {
                if (event is FlLongPressEnd) {
                  setState(() {
                    _displaySample = null;
                  });
                  return;
                }
                if (resp == null || resp.lineBarSpots == null || resp.lineBarSpots!.isEmpty) {
                  setState(() {
                    _displaySample = null;
                  });
                  return;
                }

                // Find the time from the depth line spot
                final depthSpot = resp.lineBarSpots!.where((s) => s.barIndex == depthLineIndex).firstOrNull;
                if (depthSpot == null) return;
                final time = depthSpot.x;
                final timeSeconds = (time * 60).toInt();

                // Find the sample closest to this time
                final sample = _findClosestSample(samplesWithDepth, timeSeconds);
                if (sample == null) return;

                setState(() {
                  _displaySample = sample;
                });
              },
              touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedSpots) => [for (var i = 0; i < touchedSpots.length; i++) null]),
              getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((idx) {
                if (barData.barWidth < 2) return null; // hack to identify depth line
                return TouchedSpotIndicatorData(FlLine(color: Theme.of(context).colorScheme.secondary, strokeWidth: 1), FlDotData());
              }).toList(),
              getTouchLineStart: (barData, spotIndex) => 0,
              getTouchLineEnd: (barData, spotIndex) => _chartMaxDepth,
            ),
            clipData: FlClipData.vertical(),
          ),
        ),
      ],
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
      if (sample.hasDeco()) {
        res.deco = sample.deco;
      }
    }
    return res;
  }

  /// Builds step-style graph spots from samples.
  /// For each pair of consecutive samples, adds a synthetic point just before
  /// the second sample at the first sample's Y value to create a step effect.
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
