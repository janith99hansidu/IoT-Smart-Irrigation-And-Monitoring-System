// weather_chart_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'metric_chart.dart';

class WeatherChartScreen extends StatefulWidget {
  const WeatherChartScreen({Key? key}) : super(key: key);

  @override
  _WeatherChartScreenState createState() => _WeatherChartScreenState();
}

class _WeatherChartScreenState extends State<WeatherChartScreen> {
  final List<WeatherData> dataPoints = [];
  Timer? timer;
  final WeatherApiService apiService = WeatherApiService();

  @override
  void initState() {
    super.initState();
    // Fetch the initial data point.
    fetchData();
    // Fetch data periodically (e.g., every 5 minutes).
    timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      WeatherData weather =
      await apiService.fetchCurrentWeather('Kilinochchi');
      setState(() {
        dataPoints.add(weather);
      });
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loader until data is available.
    if (dataPoints.isEmpty) {
      return Scaffold(
          appBar:  AppBar(title:  Text("Weather Time Series")),
          body: const Center(child: CircularProgressIndicator()));
    }

    return SizedBox(
      height: 800,
      child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
          childAspectRatio: 1.4
          ),
          children: [
            // Separate graphs for each parameter:
            MetricChart(
              title: 'Temperature',
              unit: '°C',
              dataPoints: dataPoints,
              getValue: (wd) => wd.tempC,
            ),
            MetricChart(
              title: 'Wind Speed',
              unit: 'mph',
              dataPoints: dataPoints,
              getValue: (wd) => wd.windMph,
            ),
            MetricChart(
              title: 'Pressure',
              unit: 'mb',
              dataPoints: dataPoints,
              getValue: (wd) => wd.pressureMb,
            ),
            MetricChart(
              title: 'Humidity',
              unit: '%',
              dataPoints: dataPoints,
              getValue: (wd) => wd.humidity.toDouble(),
            ),
            MetricChart(
              title: 'Feels Like',
              unit: '°C',
              dataPoints: dataPoints,
              getValue: (wd) => wd.feelslikeC,
            ),
            MetricChart(
              title: 'Dew Point',
              unit: '°C',
              dataPoints: dataPoints,
              getValue: (wd) => wd.dewpointC,
            ),
            MetricChart(
              title: 'Gust',
              unit: 'mph',
              dataPoints: dataPoints,
              getValue: (wd) => wd.gustMph,
            ),
          ],
      ),
    );
  }
}
