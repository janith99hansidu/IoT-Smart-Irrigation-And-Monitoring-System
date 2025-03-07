#include <Arduino.h>
#include "SensorManager.h"
#include "NetworkManager.h"
#include "Weather.h"

#include <DHT.h>
#include <DHT_U.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// Define constants
#define DHTPIN D3           // DHT11 sensor connected pin
#define DHTTYPE DHT11       // Type of the DHT sensor
#define MOISTUREPIN A0      // Moisture sensor analog pin

// WiFi credentials 
const char* ssid = "realme";
const char* password = "12345678";

// MQTT Broker details
const char* mqtt_server = "5.196.78.28";
const char* mqtt_topic = "nodemcu/dht11";

// Global variables for sensor data and timing
float moisturePercentage = 0.0;
bool pumpState = false;
unsigned long lastPublishTime = 0;
const long publishInterval = 3000;
uint32_t delayMS = 0;

// Global objects
WiFiClient espClient;
PubSubClient client(espClient);
DHT_Unified dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  // Initialize sensor
  dht.begin();
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);
  delayMS = sensor.min_delay / 1000;

  // Setup built-in LED (for testing, used as a relay output)
  pinMode(BUILTIN_LED, OUTPUT);
  
  // Connect to WiFi
  connectWiFi(ssid, password);
  
  // Setup MQTT
  setupMQTT(client, mqtt_server, mqtt_topic);
  
  // Connect to the MQTT broker
  reconnectMQTT(client, mqtt_topic);

  // get weather forecast data at startup
  getWeatherForecast();
}

void loop() {
  // Ensure WiFi connection is active
  checkWiFi(ssid, password);
  
  // Publish sensor data at the specified interval
  unsigned long now = millis();
  if (now - lastPublishTime >= publishInterval) {
    lastPublishTime = now;
    publishSensorData(dht, moisturePercentage, pumpState, client, MOISTUREPIN, mqtt_topic);
  }

  // Process incoming MQTT messages
  client.loop();
}
