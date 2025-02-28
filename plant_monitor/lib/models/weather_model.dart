// weather_model.dart
import 'dart:convert';
import "package:http/http.dart" as http;

class WeatherData {
  final DateTime time;
  final double tempC;
  final double windMph;
  final double pressureMb;
  final int humidity;
  final double feelslikeC;
  final double dewpointC;
  final double gustMph;

  WeatherData({
    required this.time,
    required this.tempC,
    required this.windMph,
    required this.pressureMb,
    required this.humidity,
    required this.feelslikeC,
    required this.dewpointC,
    required this.gustMph,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final localtime = json['location']['localtime'];
    DateTime time = DateTime.parse(localtime);
    return WeatherData(
      time: time,
      tempC: (current['temp_c'] as num).toDouble(),
      windMph: (current['wind_mph'] as num).toDouble(),
      pressureMb: (current['pressure_mb'] as num).toDouble(),
      humidity: (current['humidity'] as num).toInt(),
      feelslikeC: (current['feelslike_c'] as num).toDouble(),
      dewpointC: (current['dewpoint_c'] as num).toDouble(),
      gustMph: (current['gust_mph'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temp_c': tempC,
      'wind_mph': windMph,
      'pressure_mb': pressureMb,
      'humidity': humidity,
      'feelslike_c': feelslikeC,
      'dewpoint_c': dewpointC,
      'gust_mph': gustMph,
    };
  }
}

class WeatherApiService {
  static const String _apiKey = 'b972377fa4ea414daa374853250502';
  static const String _baseUrl = 'http://api.weatherapi.com/v1/current.json';

  Future<WeatherData> fetchCurrentWeather(String location) async {
    final url = '$_baseUrl?key=$_apiKey&q=$location';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return WeatherData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
