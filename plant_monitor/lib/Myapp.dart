import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

import 'package:plant_monitor/screens/weather_chart_screen.dart';
import 'package:plant_monitor/widgets/pump_card.dart';
import 'package:plant_monitor/widgets/sensor_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // MQTT setup
  final String broker      = 'test.mosquitto.org';
  final String sensorTopic = 'nodemcu/dht11';
  final String autoTopic   = 'nodemcu/auto';

  MqttServerClient? client;
  bool isConnected = false;

  // Sensor & pump state
  double temperature = 0.0;
  double humidity    = 0.0;
  double moisture    = 0.0;
  bool pumpState     = false;

  // Auto‑watering mode
  bool autoMode      = true;

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  Future<void> connectMQTT() async {
    client = MqttServerClient(broker, '');
    client!
      ..port = 1883
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      setState(() => isConnected = true);
      print('✅ Connected to MQTT broker');

      // Subscribe to sensor topic
      client!.subscribe(sensorTopic, MqttQos.atMostOnce);
      client!.updates!.listen(_onMessage);
    } catch (e) {
      print('❌ MQTT connection failed: $e');
      client?.disconnect();
    }
  }

  void onDisconnected() {
    setState(() => isConnected = false);
    print('⚠️ Disconnected from MQTT');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    final recMessage = events[0].payload as MqttPublishMessage;
    final rawPayload =
    MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
    print('📥 Received raw: $rawPayload');

    // --- Fix payload to valid JSON by quoting keys ---
    final fixed = rawPayload.replaceAllMapped(
      RegExp(r'(\w+)\s*:'),
          (m) => '"${m[1]}":',
    );
    print('📥 Fixed JSON: $fixed');

    try {
      final Map<String, dynamic> data = jsonDecode(fixed);
      setState(() {
        temperature = (data['temperature'] ?? 0).toDouble();
        humidity    = (data['humidity']    ?? 0).toDouble();
        moisture    = (data['moisture']    ?? 0).toDouble();
        pumpState   = (data['pumpState'] == true || data['pumpState'] == 1);
        autoMode    = (data['auto']       == 1);
      });
    } catch (e) {
      print('⚠️ JSON parse error: $e');
    }
  }

  /// Publish `auto:1` or `auto:0` to enable/disable automatic watering.
  void sendAutoMode(bool enable) {
    if (!isConnected || client == null) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString('auto:${enable ? 1 : 0}');
    client!.publishMessage(autoTopic, MqttQos.atMostOnce, builder.payload!);
    setState(() => autoMode = enable);
    print('📤 Published auto:${enable ? 1 : 0}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Irrigation Dashboard',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        connectMQTT:   connectMQTT,
        isConnected:   isConnected,
        temperature:   temperature,
        humidity:      humidity,
        moisture:      moisture,
        pumpState:     pumpState,
        autoMode:      autoMode,
        onAutoToggled: sendAutoMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback connectMQTT;
  final bool isConnected;
  final double temperature;
  final double humidity;
  final double moisture;
  final bool pumpState;
  final bool autoMode;
  final ValueChanged<bool> onAutoToggled;

  HomeScreen({
    required this.connectMQTT,
    required this.isConnected,
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.pumpState,
    required this.autoMode,
    required this.onAutoToggled,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueNotifier<double> humidityNotifier;
  late ValueNotifier<double> moistureNotifier;

  @override
  void initState() {
    super.initState();
    humidityNotifier = ValueNotifier(widget.humidity);
    moistureNotifier = ValueNotifier(widget.moisture);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.humidity != widget.humidity) {
      humidityNotifier.value = widget.humidity;
    }
    if (oldWidget.moisture != widget.moisture) {
      moistureNotifier.value = widget.moisture;
    }
  }

  @override
  void dispose() {
    humidityNotifier.dispose();
    moistureNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Irrigation System'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Weather Chart'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WeatherChartPage()),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Connect Button & Auto‑Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.isConnected ? null : widget.connectMQTT,
                  icon: Icon(
                    widget.isConnected ? Icons.check_circle : Icons.cloud_off,
                    color: widget.isConnected ? Colors.green : Colors.red,
                  ),
                  label: Text(
                    widget.isConnected ? 'Connected' : 'Connect',
                  ),
                ),
                Row(
                  children: [
                    Text('Automatic Watering'),
                    Switch(
                      value: widget.autoMode,
                      onChanged: widget.isConnected
                          ? widget.onAutoToggled
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // Sensor + Pump + Auto‑Mode Cards
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    title: 'Temperature',
                    value: '${widget.temperature.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SensorCard(
                    title: 'Humidity',
                    value: '${widget.humidity.toStringAsFixed(1)}%',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SensorCard(
                    title: 'Moisture',
                    value: '${widget.moisture.toStringAsFixed(1)}%',
                    icon: Icons.opacity,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SensorCard(
                    title: 'Auto Mode',
                    value: widget.autoMode ? 'On' : 'Off',
                    icon: Icons.autorenew,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(child: PumpCard(pumpState: widget.pumpState)),
              ],
            ),
            SizedBox(height: 48),

            // Circular Progress Bars
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: DashedCircularProgressBar.aspectRatio(
                      aspectRatio: 1,
                      valueNotifier: humidityNotifier,
                      progress: widget.humidity,
                      startAngle: 225,
                      sweepAngle: 270,
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.grey.shade200,
                      foregroundStrokeWidth: 15,
                      backgroundStrokeWidth: 15,
                      animation: true,
                      seekSize: 6,
                      seekColor: Colors.grey.shade200,
                      child: Center(
                        child: ValueListenableBuilder<double>(
                          valueListenable: humidityNotifier,
                          builder: (_, value, __) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Humidity'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DashedCircularProgressBar.aspectRatio(
                      aspectRatio: 1,
                      valueNotifier: moistureNotifier,
                      progress: widget.moisture,
                      startAngle: 225,
                      sweepAngle: 270,
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.grey.shade200,
                      foregroundStrokeWidth: 15,
                      backgroundStrokeWidth: 15,
                      animation: true,
                      seekSize: 6,
                      seekColor: Colors.grey.shade200,
                      child: Center(
                        child: ValueListenableBuilder<double>(
                          valueListenable: moistureNotifier,
                          builder: (_, value, __) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Soil Moisture'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
