import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ssrf/ssrf.dart';

class DepthProfileWidget extends StatelessWidget {
  final DiveComputer diveComputer;

  const DepthProfileWidget({super.key, required this.diveComputer});

  @override
  Widget build(BuildContext context) {
    if (diveComputer.samples.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('No depth profile data available')),
      );
    }

    // Inverting depth, so that depths are negative for graph purposes
    final maxDepth = -diveComputer.samples.map((s) => s.depth).reduce((a, b) => a > b ? a : b);
    final maxTime = diveComputer.samples.map((s) => s.time).reduce((a, b) => a > b ? a : b) / 60;
    final spots = diveComputer.samples.map((sample) => FlSpot(sample.time / 60, -sample.depth)).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: const Text('Depth (m)'),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                axisNameWidget: const Text('Time (min)'),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
            minX: 0,
            maxX: maxTime * 1.05,
            minY: maxDepth * 1.1,
            maxY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                aboveBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.3)),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.x.toStringAsFixed(1)} min\n${spot.y.toStringAsFixed(1)} m',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
