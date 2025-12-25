import 'dart:io' show Platform;

import 'package:divestore/divestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A fullscreen view of the dive depth profile.
/// On mobile devices (iOS/Android), this screen forces landscape orientation.
class FullscreenProfileScreen extends StatefulWidget {
  final ComputerDive computerDive;
  final String? title;

  const FullscreenProfileScreen({super.key, required this.computerDive, this.title});

  @override
  State<FullscreenProfileScreen> createState() => _FullscreenProfileScreenState();
}

class _FullscreenProfileScreenState extends State<FullscreenProfileScreen> {
  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
  }

  @override
  void dispose() {
    _restoreOrientation();
    super.dispose();
  }

  void _setLandscapeOrientation() {
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  void _restoreOrientation() {
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    // Filter out samples without depth data
    final samples = widget.computerDive.samples.where((s) => s.depth != null).toList();
    if (samples.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: widget.title != null ? Text(widget.title!) : null),
        body: const Center(
          child: Text('No depth profile data available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final maxDepth = -samples.map((s) => s.depth!).reduce((a, b) => a > b ? a : b);
    final maxTime = samples.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    final spots = samples.map((sample) => FlSpot(sample.time / 60, -sample.depth!)).toList();

    return Padding(
      padding: Platform.isMacOS ? const EdgeInsets.only(top: 16.0) : EdgeInsetsGeometry.only(), // avoid the window buttons on macos
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leadingWidth: 128,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: widget.title != null ? Text(widget.title!, style: const TextStyle(color: Colors.white)) : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              transformationConfig: const FlTransformationConfig(scaleAxis: FlScaleAxis.horizontal, minScale: 1.0, maxScale: 10.0),
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Depth (m)', style: TextStyle(color: Colors.white70)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      minIncluded: false,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toStringAsFixed(0).replaceFirst('-', ''),
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Time (min)', style: TextStyle(color: Colors.white70)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      maxIncluded: false,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, color: Colors.white70));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.white38)),
                minX: 0,
                maxX: maxTime * 1.05,
                minY: maxDepth * 1.1,
                maxY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    aboveBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.4)),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${formatDuration((spot.x * 60).toInt())}\n${spot.y.toStringAsFixed(1).replaceFirst('-', '')} m',
                          TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        );
                      }).toList();
                    },
                  ),
                  getTouchLineStart: (barData, spotIndex) => 0,
                  getTouchLineEnd: (barData, spotIndex) => 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
