// metric_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class MetricChart extends StatelessWidget {
  final String title;
  final String unit;
  final List<WeatherData> dataPoints;
  final double Function(WeatherData) getValue;

  const MetricChart({
    Key? key,
    required this.title,
    required this.unit,
    required this.dataPoints,
    required this.getValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the first data point as a reference for the x-axis.
    double referenceTime =
    dataPoints.first.time.millisecondsSinceEpoch.toDouble();

    // Convert WeatherData into chart spots.
    List<FlSpot> spots = dataPoints.map((wd) {
      double x = (wd.time.millisecondsSinceEpoch.toDouble() - referenceTime) /
          60000; // elapsed minutes
      return FlSpot(x, getValue(wd));
    }).toList();

    // Determine y-axis bounds with padding.
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$title ($unit)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // Adjusted chart area height
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          int minutes = value.toInt();
                          DateTime time = DateTime.fromMillisecondsSinceEpoch(
                            referenceTime.toInt() + minutes * 60000,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: ((maxY - minY) / 5).clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
