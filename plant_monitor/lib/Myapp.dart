import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:plant_monitor/screens/weather_chart_screen.dart';
import 'package:plant_monitor/widgets/pump_card.dart';
import 'dart:convert';

import 'package:plant_monitor/widgets/sensor_card.dart';
import 'package:plant_monitor/widgets/weather_chart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String broker = 'test.mosquitto.org';
  final String topic = 'nodemcu/dht11';

  MqttServerClient? client;
  bool isConnected = false;

  // Sensor data variables
  double temperature = 0.0;
  double humidity = 0.0;
  double moisture = 0.0;
  bool pumpState = false;

  Future<void> connectMQTT() async {
    client = MqttServerClient(broker, '');
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      setState(() {
        isConnected = true;
      });

      print('Connected to MQTT broker');
      client!.subscribe(topic, MqttQos.atMostOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMessage =
        c[0].payload as MqttPublishMessage;
        final payload =
        MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
        print('Received: $payload');

        // Parse JSON payload
        final Map<String, dynamic> data = jsonDecode(payload);
        setState(() {
          temperature = data['temperature']?.toDouble() ?? 0.0;
          humidity = data['humidity']?.toDouble() ?? 0.0;
          moisture = data['moisture']?.toDouble() ?? 0.0;
          pumpState = (data['pumpState'] == 1 || data['pumpState'] == true);
        });
      });
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  void onDisconnected() {
    setState(() {
      isConnected = false;
    });
    print('Disconnected from MQTT');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: HomeScreen(connectMQTT, isConnected, temperature, humidity,
          moisture, pumpState),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback connectMQTT;
  final bool isConnected;
  final double temperature;
  final double humidity;
  final double moisture;
  final bool pumpState;

  HomeScreen(this.connectMQTT, this.isConnected, this.temperature,
      this.humidity, this.moisture, this.pumpState);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Smart Irrigation System Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Weather Chart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WeatherChartPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: isConnected ? null : connectMQTT,
                  icon: Icon(Icons.connect_without_contact),
                  label: Text(
                    isConnected ? 'Connected' : 'Connect',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey[850],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Sensor Cards
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    title: 'Temperature',
                    value: '${temperature.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SensorCard(
                    title: 'Humidity',
                    value: '${humidity.toStringAsFixed(1)}%',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SensorCard(
                    title: 'Moisture',
                    value: '${moisture.toStringAsFixed(1)}%',
                    icon: Icons.opacity,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: PumpCard(pumpState: pumpState),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(child: WeatherChartScreen()),
          ]),
        ),
      ),
    );
  }
}


