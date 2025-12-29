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

    final unit = context.watch<PreferencesBloc>().state.preferences.depthUnit;
    final mult = unit == DepthUnit.feet ? 3.28 : 1.0;

    if (samplesWithDepth.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('No depth profile data available')),
      );
    }

    // Inverting depth, so that depths are negative for graph purposes
    final maxDepth = mult * -samplesWithDepth.map((s) => s.depth).reduce((a, b) => a > b ? a : b);
    final maxTime = samplesWithDepth.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    final spots = samplesWithDepth.map((sample) => FlSpot(sample.time / 60, mult * -sample.depth)).toList();

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final borderColor = colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text('Depth (${unit.name})'),
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
            maxX: maxTime * 1.05,
            minY: maxDepth * 1.1,
            maxY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: primaryColor,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                aboveBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.3)),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${formatDuration((spot.x * 60).toInt())}\n${formatDepth(context, -spot.y)}',
                      TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12),
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
    );
  }
}
