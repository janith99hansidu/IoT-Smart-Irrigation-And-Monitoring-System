import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Smart Farm Dashboard'),
          backgroundColor: Colors.black87,
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
                      child: _buildInfoCard(
                        context,
                        title: 'Temperature',
                        value: '${temperature.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        title: 'Humidity',
                        value: '${humidity.toStringAsFixed(1)}%',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Row of "Moisture" and "Pump State"
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        title: 'Moisture',
                        value: '${moisture.toStringAsFixed(1)}%',
                        icon: Icons.opacity,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildPumpCard(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget: Basic info card with title, value, icon
  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    // Dynamically set font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.03; // 4% of width
    double valueFontSize = screenWidth * 0.05; // 5% of width

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper widget: Pump State card (On/Off)
  Widget _buildPumpCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.03;
    double valueFontSize = screenWidth * 0.05;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            pumpState ? Icons.power : Icons.power_off,
            size: 40,
            color: pumpState ? Colors.green : Colors.red,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pump',
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 8),
              Text(
                pumpState ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: valueFontSize,
                  color: pumpState ? Colors.green : Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
