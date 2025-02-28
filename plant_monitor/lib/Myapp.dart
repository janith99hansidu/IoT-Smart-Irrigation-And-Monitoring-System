import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
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
        final MqttPublishMessage recMessage = c[0].payload as MqttPublishMessage;
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
      theme: ThemeData.light().copyWith(
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Smart Farm Dashboard')
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Connection Status / Button
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

                // Row of "Current Temperature" and "Humidity"
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

                // Row of "Moisture" and "Pump State
                WeatherChartScreen(),
              ]
            ),
          ),
        ),
      ),
    );
  }

}
