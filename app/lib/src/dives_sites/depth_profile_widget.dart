import 'dart:async';

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
  final VoidCallback? onTap;

  DepthProfile({super.key, required this.dive, this.onTap}) : log = dive.logs.firstOrNull ?? Log();

  @override
  State<DepthProfile> createState() => _DepthProfileState();
}

class _ProfileAnnotationPainter extends FlDotCirclePainter {
  final String label;
  final Color background;
  final TextDirection textDirection;
  final bool above;

  _ProfileAnnotationPainter({required this.label, required super.color, required this.background, required this.textDirection, this.above = false})
    : super(radius: 4, strokeWidth: 2, strokeColor: background);

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    super.draw(canvas, spot, offsetInCanvas);
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: textDirection,
    )..layout();
    final bounds = canvas.getLocalClipBounds();
    final left = (offsetInCanvas.dx - text.width / 2).clamp(bounds.left + 2, (bounds.right - text.width - 2).clamp(bounds.left + 2, double.infinity));
    final offset = Offset(left, above ? offsetInCanvas.dy - text.height - 8 : offsetInCanvas.dy + 8);
    canvas.drawRRect(RRect.fromRectAndRadius((offset & text.size).inflate(2), const Radius.circular(2)), Paint()..color = background);
    text.paint(canvas, offset);
    text.dispose();
  }

  @override
  List<Object?> get props => [...super.props, label, background, textDirection, above];
}

class _DepthProfileState extends State<DepthProfile> {
  static const _chartBorderWidth = 1.0;
  static const _leftTitleWidth = 24.0;
  static const _bottomTitleHeight = 16.0;
  static const sacPalette = [
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

  final _hoverChanges = ValueNotifier<int>(0);
  final List<LogSample> _inspectionSamples = [];
  LogSample? _displaySample;
  Timer? _infoHideTimer;
  bool _infoVisible = false;
  double? _inspectionTime;
  LogSample? _decoAnnotationSample;
  double _maxTime = 0;
  double _chartMaxDepth = 0;
  final List<FlSpot> _tempSpots = [];
  final Map<FlSpot, double> _temperatureExtrema = {};
  final List<LogSample> samplesWithDepth = [];
  final List<FlSpot> _depthSpots = [];
  final List<FlSpot> _ceilingSpots = [];
  final List<FlSpot> _buhlmannCeilingSpots = [];
  final List<({double time, double ceiling, double surfGF})> _buhlmann = [];
  final _pressureData = <int, ({List<FlSpot> spots, List<double> times, List<double> sac, double minPressure, double maxPressure})>{};
  final _gasSwitches = <({double timeMinutes, double oxygen, double helium})>[];
  final _buhlmannByTime = <double, ({double time, double ceiling, double surfGF})>{};
  final List<double?> _inspectionSac = [];
  double? _displaySac;
  LineChartData? _chartData;
  DiveListState? _lastDiveListState;
  double _averageSac = 0;

  DepthUnit? _lastDepthUnit;
  double? _lastGfLow;
  double? _lastGfHigh;

  @override
  void dispose() {
    _infoHideTimer?.cancel();
    _hoverChanges.dispose();
    super.dispose();
  }

  void _scheduleInfoHide() {
    _infoHideTimer?.cancel();
    _infoHideTimer = Timer(const Duration(seconds: 5), () {
      _infoVisible = false;
      _hoverChanges.value++;
    });
  }

  @override
  void initState() {
    super.initState();
    _buildData(context.read<PreferencesStore>());
  }

  @override
  void didUpdateWidget(covariant DepthProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.dive, widget.dive) || !identical(oldWidget.log, widget.log)) {
      _buildData(context.read<PreferencesStore>());
      _chartData = samplesWithDepth.isEmpty ? null : _buildChartData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = context.watch<PreferencesStore>();
    if (_lastDepthUnit != prefs.depthUnit || _lastGfLow != prefs.gfLow || _lastGfHigh != prefs.gfHigh) {
      _buildData(prefs);
    }
    final diveListState = context.watch<DiveListBloc>().state;
    if (!identical(_lastDiveListState, diveListState)) {
      _lastDiveListState = diveListState;
      var total = 0.0;
      var count = 0;
      if (diveListState is DiveListLoaded) {
        for (final dive in diveListState.dives) {
          if (dive.sac > 0 && dive.sac.isFinite) {
            total += dive.sac;
            count++;
          }
        }
      }
      _averageSac = count > 0 ? total / count : 0;
    }
    // Labels and colours depend on inherited locale, direction, units and theme.
    _chartData = samplesWithDepth.isEmpty ? null : _buildChartData();
  }

  void _buildData(PreferencesStore prefs) {
    _lastDepthUnit = prefs.depthUnit;
    _lastGfLow = prefs.gfLow;
    _lastGfHigh = prefs.gfHigh;
    _infoHideTimer?.cancel();
    _displaySample = null;
    _displaySac = null;
    _inspectionTime = null;
    _infoVisible = false;
    _maxTime = 0;
    _chartMaxDepth = 0;
    _inspectionSac.clear();
    _buhlmannByTime.clear();
    samplesWithDepth.clear();
    _inspectionSamples.clear();
    _depthSpots.clear();
    _tempSpots.clear();
    _temperatureExtrema.clear();
    _ceilingSpots.clear();
    _buhlmannCeilingSpots.clear();
    _buhlmann.clear();
    _pressureData.clear();
    _gasSwitches.clear();
    _decoAnnotationSample = null;

    // Filter out samples without depth data
    samplesWithDepth.addAll(widget.log.samples.where((s) => s.hasDepth()));
    final lastNonZeroIdx = samplesWithDepth.lastIndexWhere((s) => s.depth != 0);
    if (lastNonZeroIdx < samplesWithDepth.length - 2) {
      // Trim tail of zero samples
      samplesWithDepth.removeRange(lastNonZeroIdx + 2, samplesWithDepth.length);
    }

    if (samplesWithDepth.isEmpty) return;

    // Carry sparse readings forward once, rather than scanning the dive on every hover.
    final inspectionSample = LogSample();
    for (final sample in samplesWithDepth) {
      inspectionSample.time = sample.time;
      inspectionSample.depth = sample.depth;
      if (sample.hasTemperature()) inspectionSample.temperature = sample.temperature;
      if (sample.pressures.isNotEmpty) {
        inspectionSample.pressures
          ..clear()
          ..addAll(sample.pressures);
      }
      if (sample.hasDeco()) inspectionSample.deco = sample.deco;
      _inspectionSamples.add(inspectionSample.deepCopy());
    }

    final depthUnit = prefs.depthUnit;
    final depthMult = depthUnit == .feet ? 3.28 : 1.0;

    // Depth data
    final maxDepth = depthMult * -samplesWithDepth.map((s) => s.depth).reduce((a, b) => a > b ? a : b);
    // Leave room below the deepest sample for its annotation.
    _chartMaxDepth = ((maxDepth * 1.2 ~/ 3) - 1).toDouble() * 3;
    _maxTime = samplesWithDepth.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    _depthSpots.addAll(samplesWithDepth.map((sample) => FlSpot(sample.time / 60, depthMult * -sample.depth)));

    // Temperature data - normalize to depth range, step-style
    final samplesWithTemp = samplesWithDepth.where((s) => s.hasTemperature() && s.temperature != 0).toList();
    double minTemp = 0, maxTemp = 0;
    if (samplesWithTemp.isNotEmpty) {
      minTemp = samplesWithTemp.map((s) => s.temperature).reduce((a, b) => a < b ? a : b);
      maxTemp = samplesWithTemp.map((s) => s.temperature).reduce((a, b) => a > b ? a : b);
      final tempRange = maxTemp - minTemp;
      double normalizeTemp(double temp) {
        if (tempRange == 0) return maxDepth * 0.8;
        final normalized = (temp - minTemp) / tempRange;
        return maxDepth * 0.9 - normalized * (maxDepth * 0.2);
      }

      _tempSpots.addAll(_buildStepSpots(samplesWithTemp, (s) => s.time / 60, (s) => normalizeTemp(s.temperature), _maxTime));
      // Use actual samples so synthetic step points cannot move the markers.
      for (final temperature in {minTemp, maxTemp}) {
        final sample = samplesWithTemp.firstWhere((s) => s.temperature == temperature);
        _temperatureExtrema[FlSpot(sample.time / 60, normalizeTemp(temperature))] = temperature;
      }
    }

    // Deco ceiling (from dive computer)
    LogSample? lowestNdl;
    LogSample? highestTts;
    final reportedDecoValues = <(DecoStopType, int)>{};
    for (final sample in samplesWithDepth) {
      if (!sample.hasDeco()) continue;
      final deco = sample.deco;
      if (deco.type == .DECO_STOP_TYPE_DECO_STOP && deco.depth > 0) {
        reportedDecoValues.add((deco.type, deco.tts));
        if (highestTts == null || deco.tts > highestTts.deco.tts || (deco.tts == highestTts.deco.tts && deco.depth > highestTts.deco.depth)) {
          highestTts = sample;
        }
      } else if (deco.type == .DECO_STOP_TYPE_NDL && deco.time > 0) {
        reportedDecoValues.add((deco.type, deco.time));
        if (lowestNdl == null || deco.time < lowestNdl.deco.time) {
          lowestNdl = sample;
        }
      }
    }

    // Constant values usually represent a computer's placeholder or limit.
    _decoAnnotationSample = reportedDecoValues.length > 1 ? highestTts ?? lowestNdl : null;
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

    final pressureIndices = <int, int>{};
    for (final sample in _inspectionSamples) {
      double? sac;
      if (sample.pressures.isNotEmpty && sample.pressures.first.pressure > 0) {
        final tankIndex = sample.pressures.first.tankIndex;
        final data = _pressureData[tankIndex];
        final time = sample.time / 60;
        if (data != null && data.sac.length >= 2 && time >= data.times.first) {
          var index = pressureIndices[tankIndex] ?? 0;
          while (index + 1 < data.times.length && data.times[index + 1] <= time) {
            index++;
          }
          pressureIndices[tankIndex] = index;
          sac = data.sac[index];
        }
      }
      _inspectionSac.add(sac);
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
            _gasSwitches.add((timeMinutes: 0, oxygen: widget.dive.cylinders.first.oxygen, helium: widget.dive.cylinders.first.helium));
          }
          final cyl = widget.dive.cylinders[event.value];
          _gasSwitches.add((timeMinutes: event.time / 60, oxygen: cyl.oxygen, helium: cyl.helium));
        }
      }
    }
  }

  LineChartData _buildChartData() {
    final textDirection = Directionality.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final borderColor = colorScheme.outline;
    final tempColor = Colors.cyan;
    final pressureColors = [Colors.orange, Colors.green, Colors.lime, Colors.teal];
    final ceilingColor = Colors.red;
    final buhlmannCeilingColor = Colors.deepPurple;
    final deepestSpot = _depthSpots.reduce((a, b) => a.y <= b.y ? a : b);
    final deepestIndex = _depthSpots.indexOf(deepestSpot);
    final deepestLabel = formatDepth(context.l10n, _lastDepthUnit!, samplesWithDepth[deepestIndex].depth);

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
        dotData: FlDotData(
          // Chart animations recreate spots, so compare their coordinates.
          checkToShowDot: (spot, bar) => spot == deepestSpot,
          getDotPainter: (spot, percent, bar, index) =>
              _ProfileAnnotationPainter(label: deepestLabel, color: primaryColor, background: colorScheme.surface, textDirection: textDirection),
        ),
        aboveBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.3)),
      ),
    );

    // Temperature line
    if (_tempSpots.isNotEmpty) {
      final temperatureUnit = context.read<PreferencesStore>().temperatureUnit;
      final maxTemperature = _temperatureExtrema.values.reduce((a, b) => a > b ? a : b);
      lineBars.add(
        LineChartBarData(
          spots: _tempSpots,
          color: tempColor,
          barWidth: 1,
          dotData: FlDotData(
            checkToShowDot: (spot, bar) => _temperatureExtrema.containsKey(spot),
            getDotPainter: (spot, percent, bar, index) => _ProfileAnnotationPainter(
              label: formatTemperature(context.l10n, temperatureUnit, _temperatureExtrema[spot]!),
              above: _temperatureExtrema[spot] == maxTemperature,
              color: tempColor,
              background: colorScheme.surface,
              textDirection: textDirection,
            ),
          ),
          dashArray: [4, 2],
        ),
      );
    }

    // Pressure lines
    final averageSac = _averageSac;
    final minSac = averageSac / 2;
    final maxSac = averageSac * 2;
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

    final decoSample = _decoAnnotationSample;
    if (decoSample != null) {
      final deco = decoSample.deco;
      final isDeco = deco.type == .DECO_STOP_TYPE_DECO_STOP;
      final label = isDeco ? context.l10n.tts(formatMinutes(context.l10n, deco.tts)) : context.l10n.ndl(formatMinutes(context.l10n, deco.time));
      final depthMult = _lastDepthUnit == .feet ? 3.28 : 1.0;
      lineBars.add(
        LineChartBarData(
          spots: [FlSpot(decoSample.time / 60, isDeco ? -deco.depth * depthMult : 0)],
          barWidth: 0,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) =>
                _ProfileAnnotationPainter(label: label, color: ceilingColor, background: colorScheme.surface, textDirection: textDirection),
          ),
        ),
      );
    }

    final gasLabels = [for (final gs in _gasSwitches) formatGasFraction(context, gs.oxygen, gs.helium)];
    return LineChartData(
      backgroundColor: Colors.transparent,
      gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            minIncluded: false,
            reservedSize: _leftTitleWidth,
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
            reservedSize: _bottomTitleHeight,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: borderColor, width: _chartBorderWidth),
      ),
      minX: 0,
      maxX: _maxTime + 0.5, // minutes
      minY: _chartMaxDepth,
      maxY: 0,
      lineBarsData: lineBars,
      extraLinesData: ExtraLinesData(
        verticalLines: [
          // Gas switches
          for (var i = 0; i < _gasSwitches.length; i++)
            VerticalLine(
              x: _gasSwitches[i].timeMinutes,
              color: colorScheme.tertiary.withValues(alpha: 0.7),
              strokeWidth: 1,
              dashArray: [2, 2],
              label: VerticalLineLabel(
                show: true,
                alignment: .bottomRight,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.tertiary),
                labelResolver: (line) => gasLabels[i],
              ),
            ),
        ],
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: false,
        touchCallback: (event, resp) {
          if (event is FlTapUpEvent) widget.onTap?.call();
          if (event is FlLongPressEnd) {
            _infoHideTimer?.cancel();
            _infoVisible = false;
            _inspectionTime = null;
            _hoverChanges.value++;
            return;
          }
          if (!event.isInterestedForInteractions || resp == null || resp.lineBarSpots == null || resp.lineBarSpots!.isEmpty) {
            if (_inspectionTime != null) {
              _inspectionTime = null;
              _hoverChanges.value++;
            }
            if (_infoVisible) _scheduleInfoHide();
            return;
          }

          // Find the time from the depth line spot
          final depthSpot = resp.lineBarSpots!.where((s) => s.barIndex == depthLineIndex).firstOrNull;
          if (depthSpot == null) return;
          final time = depthSpot.x;
          _scheduleInfoHide();
          if (_inspectionTime == time && _infoVisible) return;
          _displaySample = _inspectionSamples[depthSpot.spotIndex];
          _displaySac = _inspectionSac[depthSpot.spotIndex];
          _inspectionTime = time;
          _infoVisible = true;
          _hoverChanges.value++;
        },
      ),
      clipData: .vertical(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _chartData;
    if (chartData == null) {
      return Center(
        child: Padding(padding: .all(16.0), child: Text(context.l10n.noDepthProfileDataAvailable)),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        RepaintBoundary(child: LineChart(chartData)),

        // Hover updates repaint only these overlays, leaving the chart cached.
        Positioned.fill(
          left: _leftTitleWidth + _chartBorderWidth,
          top: _chartBorderWidth,
          right: _chartBorderWidth,
          bottom: _bottomTitleHeight + _chartBorderWidth,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: ListenableBuilder(
                listenable: _hoverChanges,
                builder: (context, child) => LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      if (_inspectionTime case final time?)
                        Positioned(
                          left: time / (_maxTime + 0.5) * constraints.maxWidth,
                          top: 0,
                          bottom: 0,
                          child: ColoredBox(color: colorScheme.secondary, child: const SizedBox(width: 1)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: _hoverChanges,
          builder: (context, child) {
            if (_displaySample == null) return const SizedBox.shrink();
            final buhlmann = _buhlmannByTime[_displaySample!.time];
            final selectedSac = _displaySac;
            return RepaintBoundary(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _infoVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
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
                        if (buhlmann != null) Text(context.l10n.surfaceGradientFactorValue(buhlmann.surfGF.round().clamp(0, 999))),
                        if (_displaySample!.hasDeco() && _displaySample!.deco.depth > 0) DepthText(_displaySample!.deco.depth, prefix: context.l10n.compCeil),
                        if (buhlmann != null && buhlmann.ceiling > 0) DepthText(buhlmann.ceiling, prefix: context.l10n.calcCeil),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
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
          final value = (time: sample.time, ceiling: deco.displayCeiling(), surfGF: deco.surfaceGradientFactor());
          _buhlmann.add(value);
          _buhlmannByTime[sample.time] = value;
        }
      },
    );
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
