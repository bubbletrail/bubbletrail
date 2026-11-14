import 'package:btbuhlmann/btbuhlmann.dart' as buhlmann;
import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../common/common.dart';
import '../preferences/preferences_store.dart';
import 'dive_list_bloc.dart';
import 'tissue_calculator.dart';

class DepthProfile extends StatefulWidget {
  final Dive dive;
  final Log log;

  DepthProfile({super.key, required this.dive}) : log = dive.logs.firstOrNull ?? Log();

  @override
  State<DepthProfile> createState() => _DepthProfileState();
}

class _DepthProfileState extends State<DepthProfile> {
  LogSample? _displaySample;
  double _maxTime = 0;
  double _chartMaxDepth = 0;
  final List<FlSpot> _tempSpots = [];
  final List<LogSample> samplesWithDepth = [];
  final List<FlSpot> _depthSpots = [];
  final List<FlSpot> _ceilingSpots = [];
  final List<FlSpot> _buhlmannCeilingSpots = [];
  final List<({double time, double ceiling, double surfGF})> _buhlmann = [];
  final _pressureData = <int, ({List<FlSpot> spots, List<double> times, List<double> sac, double minPressure, double maxPressure})>{};
  final _gasSwitches = <({double timeMinutes, String gasName})>[];

  Locale? _lastLocale;
  DepthUnit? _lastDepthUnit;
  double? _lastGfLow;
  double? _lastGfHigh;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = context.watch<PreferencesStore>();
    final locale = Localizations.localeOf(context);
    final needsRebuild = _lastLocale != locale || _lastDepthUnit != prefs.depthUnit || _lastGfLow != prefs.gfLow || _lastGfHigh != prefs.gfHigh;

    if (needsRebuild) {
      _lastLocale = locale;
      _lastDepthUnit = prefs.depthUnit;
      _lastGfLow = prefs.gfLow;
      _lastGfHigh = prefs.gfHigh;
      _buildData(prefs);
    }
  }

  void _buildData(PreferencesStore prefs) {
    samplesWithDepth.clear();
    _depthSpots.clear();
    _tempSpots.clear();
    _ceilingSpots.clear();
    _buhlmannCeilingSpots.clear();
    _buhlmann.clear();
    _pressureData.clear();
    _gasSwitches.clear();

    // Filter out samples without depth data
    samplesWithDepth.addAll(widget.log.samples.where((s) => s.hasDepth()));
    final lastNonZeroIdx = samplesWithDepth.lastIndexWhere((s) => s.depth != 0);
    if (lastNonZeroIdx < samplesWithDepth.length - 2) {
      // Trim tail of zero samples
      samplesWithDepth.removeRange(lastNonZeroIdx + 2, samplesWithDepth.length);
    }

    if (samplesWithDepth.isEmpty) return;

    final depthUnit = prefs.depthUnit;
    final depthMult = depthUnit == .feet ? 3.28 : 1.0;

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

    // Deco ceiling (from dive computer)
    var inDeco = false;
    for (final sample in samplesWithDepth) {
      final hasCeiling = sample.deco.type == .DECO_STOP_TYPE_DECO_STOP && sample.deco.depth > 0;
      if (hasCeiling) {
        final t = sample.time / 60;
        final ceilingDepth = sample.deco.depth * -depthMult;
        if (!inDeco) {
          // Starting point for left vertical edge
          _ceilingSpots.add(FlSpot(t, 0));
        }
        _ceilingSpots.add(FlSpot(t, ceilingDepth));
        inDeco = true;
      } else if (inDeco) {
        // Ending point for right vertical edge
        _ceilingSpots.add(FlSpot(_ceilingSpots.last.x, 0));
        inDeco = false;
      }
    }

    // Buhlmann calculated ceiling & surfGF
    _calculateBuhlmann(prefs.gfLow, prefs.gfHigh);
    inDeco = false;
    for (final sample in _buhlmann) {
      if (sample.ceiling > 0) {
        final t = sample.time / 60;
        final ceilingDepth = sample.ceiling * -depthMult;
        if (!inDeco) {
          // Starting point for left vertical edge
          _buhlmannCeilingSpots.add(FlSpot(t, 0));
        }
        _buhlmannCeilingSpots.add(FlSpot(t, ceilingDepth));
        inDeco = true;
      } else if (inDeco) {
        // Ending point for right vertical edge
        _buhlmannCeilingSpots.add(FlSpot(_buhlmannCeilingSpots.last.x, 0));
        inDeco = false;
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
        final volume = tankIndex < widget.dive.cylinders.length ? widget.dive.cylinders[tankIndex].cylinder.volumeL : 0.0;
        _pressureData[tankIndex] = (
          spots: spots,
          times: samplesWithPressure.map((s) => s.time / 60).toList(),
          sac: volume > 0 ? pressureSac(samplesWithPressure, tankIndex, volume) : [],
          minPressure: minPressure,
          maxPressure: maxPressure,
        );
      }
    }

    if (widget.dive.cylinders.length > 1) {
      // Find gas switches
      for (final event in widget.dive.events) {
        if (event.type == .SAMPLE_EVENT_TYPE_GAS_CHANGE) {
          if (event.value >= widget.dive.cylinders.length) continue;
          if (event.time > samplesWithDepth.first.time && event.value != 0 && _gasSwitches.isEmpty) {
            // We're switching to a non-default gas, without having switched
            // to the default gas, so for illustrative purposes we add a
            // synthetic switch at the first sample.
            _gasSwitches.add((timeMinutes: 0, gasName: formatGasFraction(context, widget.dive.cylinders.first.oxygen, widget.dive.cylinders.first.helium)));
          }
          final cyl = widget.dive.cylinders[event.value];
          final gasName = formatGasFraction(context, cyl.oxygen, cyl.helium);
          _gasSwitches.add((timeMinutes: event.time / 60, gasName: gasName));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (samplesWithDepth.isEmpty) {
      return Center(
        child: Padding(padding: .all(16.0), child: Text(context.l10n.noDepthProfileDataAvailable)),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final borderColor = colorScheme.outline;
    final tempColor = Colors.cyan;
    final pressureColors = [Colors.orange, Colors.green, Colors.lime, Colors.teal];
    final ceilingColor = Colors.red;
    final buhlmannCeilingColor = Colors.deepPurple;

    // Build line bars
    final lineBars = <LineChartBarData>[];

    // Buhlmann calculated ceiling - dashed purple line
    if (_buhlmannCeilingSpots.isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: _buhlmannCeilingSpots,
          color: buhlmannCeilingColor,
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          dashArray: [6, 3],
          aboveBarData: BarAreaData(show: true, color: buhlmannCeilingColor.withValues(alpha: 0.2), cutOffY: 0, applyCutOffY: true),
        ),
      );
    }

    // Deco ceiling (from dive computer) - solid red line
    if (_ceilingSpots.isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: _ceilingSpots,
          color: ceilingColor,
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          aboveBarData: BarAreaData(show: true, color: ceilingColor.withValues(alpha: 0.2), cutOffY: 0, applyCutOffY: true),
          dashArray: [3, 1],
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
    final averageSac = context.select<DiveListBloc, double>((bloc) {
      final state = bloc.state;
      if (state is! DiveListLoaded) return 0;
      var total = 0.0;
      var count = 0;
      for (final dive in state.dives) {
        if (dive.sac > 0 && dive.sac.isFinite) {
          total += dive.sac;
          count++;
        }
      }
      return count > 0 ? total / count : 0;
    });
    final minSac = averageSac / 2;
    final maxSac = averageSac * 2;
    const sacPalette = [
      Color(0xffaa3355),
      Color(0xffcc6666),
      Color(0xffee9944),
      Color(0xffeedd00),
      Color(0xff99dd55),
      Color(0xff44dd88),
      Color(0xff22ccbb),
      Color(0xff00bbcc),
      Color(0xff0099cc),
      Color(0xff3366bb),
    ];
    var pressureColorIdx = 0;
    for (final entry in _pressureData.entries) {
      final data = entry.value;
      final colors = <Color>[];
      final stops = <double>[];
      if (averageSac > 0 && data.sac.length > 1 && data.times.last > data.times.first) {
        final span = data.spots.last.x - data.times.first;
        for (var i = 0; i < data.sac.length; i++) {
          final fraction = ((data.sac[i] - minSac) / (maxSac - minSac)).clamp(0.0, 1.0);
          final index = ((1 - fraction) * sacPalette.length).floor().clamp(0, sacPalette.length - 1);
          final color = sacPalette[index];
          // Duplicate stops at sample boundaries keep the palette stepped.
          colors.addAll([color, color]);
          stops.addAll([
            (data.times[i] - data.times.first) / span,
            ((i + 1 < data.times.length ? data.times[i + 1] : data.spots.last.x) - data.times.first) / span,
          ]);
        }
      }
      lineBars.add(
        LineChartBarData(
          spots: entry.value.spots,
          color: pressureColors[pressureColorIdx % pressureColors.length],
          barWidth: 2,
          gradient: colors.isNotEmpty ? LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: colors, stops: stops) : null,
          dotData: const FlDotData(show: false),
        ),
      );
      pressureColorIdx++;
    }

    final buhlmann = _buhlmann.firstWhereOrNull((s) => s.time == _displaySample?.time);
    final selectedSac = _selectedSac();
    return Stack(
      children: [
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
                      padding: const .only(right: 8.0),
                      child: Text(value.toStringAsFixed(0).replaceFirst('-', ''), style: const TextStyle(fontSize: 10), textAlign: .right),
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
            extraLinesData: ExtraLinesData(
              // gas switches
              verticalLines: [
                for (final gs in _gasSwitches)
                  VerticalLine(
                    x: gs.timeMinutes,
                    color: colorScheme.tertiary.withValues(alpha: 0.7),
                    strokeWidth: 1,
                    dashArray: [2, 2],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: .bottomRight,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.tertiary),
                      labelResolver: (line) => gs.gasName,
                    ),
                  ),
              ],
            ),
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
                if (!identical(barData, lineBars[depthLineIndex])) return null;
                return TouchedSpotIndicatorData(FlLine(color: Theme.of(context).colorScheme.secondary, strokeWidth: 1), FlDotData());
              }).toList(),
              getTouchLineStart: (barData, spotIndex) => 0,
              getTouchLineEnd: (barData, spotIndex) => _chartMaxDepth,
            ),
            clipData: .vertical(),
          ),
        ),

        // Top info line
        if (_displaySample != null)
          Padding(
            padding: const .only(top: 8, left: 48),
            child: Row(
              spacing: 16,
              children: [
                Text(formatDuration(_displaySample!.time.toInt())),
                DepthText(_displaySample!.depth),
                if (_displaySample!.hasTemperature()) TemperatureText(_displaySample!.temperature),
                if (_displaySample!.pressures.isNotEmpty && _displaySample!.pressures.first.pressure > 0)
                  PressureText(_displaySample!.pressures.first.pressure),
                if (selectedSac != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(context.l10n.sac),
                      VolumeText(selectedSac, suffix: context.l10n.perMinute, precise: true),
                    ],
                  ),
                if (_displaySample!.hasDeco() && _displaySample!.deco.depth > 0) DepthText(_displaySample!.deco.depth, prefix: context.l10n.compCeil),
                if (buhlmann != null && buhlmann.ceiling > 0) DepthText(buhlmann.ceiling, prefix: context.l10n.calcCeil),
                if (buhlmann != null) Text(context.l10n.surfaceGradientFactorValue(buhlmann.surfGF.round().clamp(0, 999))),
              ],
            ),
          ),
      ],
    );
  }

  double? _selectedSac() {
    final sample = _displaySample;
    if (sample == null || sample.pressures.isEmpty || sample.pressures.first.pressure <= 0) return null;
    final data = _pressureData[sample.pressures.first.tankIndex];
    if (data == null || data.sac.length < 2) return null;
    final time = sample.time / 60;
    if (time < data.times.first) return null;
    for (var i = 1; i < data.times.length; i++) {
      if (data.times[i] > time) {
        return data.sac[i - 1];
      }
    }
    return data.sac.last;
  }

  void _calculateBuhlmann(double gfLow, double gfHigh) {
    if (samplesWithDepth.isEmpty) return;

    final config = buhlmann.BuhlmannConfig(
      gfLow: gfLow,
      gfHigh: gfHigh,
      surfacePressure: widget.log.hasAtmosphericPressure() ? widget.log.atmosphericPressure : buhlmann.atmPressure,
    );

    calculateDiveTissues(
      dive: widget.dive,
      startTissues: protoToTissueState(widget.dive.startTissues),
      config: config,
      onSample: (sample, deco) {
        if (sample.hasDepth()) {
          _buhlmann.add((time: sample.time, ceiling: deco.displayCeiling(), surfGF: deco.surfaceGradientFactor()));
        }
      },
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

// Centered one-minute SAC in litres/minute. At the edges, use the first or
// last minute; for shorter recordings, use the entire available interval.
// Fit a linear pressure trend through all readings in each window. Samples
// must have depth and positive pressure for [tankIndex], in time order.
List<double> pressureSac(List<LogSample> samples, int tankIndex, double volume) {
  if (samples.length < 2) return List<double>.filled(samples.length, 0);
  double pressure(int i) => samples[i].pressures.firstWhere((p) => p.tankIndex == tankIndex).pressure;
  double ambient(int i) => 1 + samples[i].depth / 10;

  final rates = List<double>.filled(samples.length, 0);
  final firstTime = samples.first.time;
  final lastTime = samples.last.time;
  final window = (lastTime - firstTime).clamp(0.0, 60.0);
  var start = 0;
  var end = 0;
  for (var i = 0; i < samples.length; i++) {
    final startTime = (samples[i].time - window / 2).clamp(firstTime, lastTime - window).toDouble();
    final endTime = startTime + window;
    while (start + 1 < samples.length && (samples[start + 1].time - startTime).abs() <= (samples[start].time - startTime).abs()) {
      start++;
    }
    while (end + 1 < samples.length && (samples[end + 1].time - endTime).abs() <= (samples[end].time - endTime).abs()) {
      end++;
    }
    final count = end - start + 1;
    var totalAmbient = 0.0;
    var totalTime = 0.0;
    var totalPressure = 0.0;
    for (var j = start; j <= end; j++) {
      totalAmbient += ambient(j);
      totalTime += samples[j].time - samples[start].time;
      totalPressure += pressure(j);
    }
    final averageAmbient = totalAmbient / count;
    final meanTime = totalTime / count;
    final meanPressure = totalPressure / count;
    var covariance = 0.0;
    var variance = 0.0;
    for (var j = start; j <= end; j++) {
      final time = samples[j].time - samples[start].time - meanTime;
      covariance += time * (pressure(j) - meanPressure);
      variance += time * time;
    }
    if (variance > 0 && averageAmbient > 0) {
      final pressureDropPerMinute = (-covariance / variance * 60).clamp(0.0, double.infinity);
      rates[i] = pressureDropPerMinute * volume / averageAmbient;
    }
  }
  return rates;
}
