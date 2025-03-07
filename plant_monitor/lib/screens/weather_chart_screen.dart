// New screen for Weather Chart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/weather_chart_screen.dart';

class WeatherChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Chart')),
      body: WeatherChartScreen(),
    );
  }
}