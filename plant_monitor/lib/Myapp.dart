import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String broker = 'test.mosquitto.org';
  final String topic = 'nodemcu/dht11';
  MqttServerClient? client;
  double temperature = 0.0;
  double humidity = 0.0;
  bool isConnected = false;

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
          temperature = data['temperature'];
          humidity = data['humidity'];
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
      home: Scaffold(
        appBar: AppBar(title: Text('DHT11 Sensor Data')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isConnected ? null : connectMQTT,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.connect_without_contact),
                    Text(isConnected ? 'Connected' : 'Connect',
                      style: TextStyle(color: isConnected ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text('Temperature: $temperature°C', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Text('Humidity:', style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: humidity / 100, // Convert to 0.0 - 1.0 range
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text('${humidity.toStringAsFixed(1)}%', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
