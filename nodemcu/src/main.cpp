#include <Arduino.h>
#include <DHT.h>
#include <DHT_U.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// access api for 1 day = http://api.weatherapi.com/v1/forecast.json?key=b972377fa4ea414daa374853250502&q=Kilinochchi&days=1
const String apiKey = "b972377fa4ea414daa374853250502";
const String location = "Kilinochchi";

// define the constants
#define DHTPIN D3 // DHT11 sensor connected pin
#define DHTTYPE DHT11 // Type of the DHT sensor
#define MOISTUREPIN A0 // moisture pin of the

// Function declarations 
void publishSensorData();
void reconnect();
void checkWiFi();
void callback(char* topic, byte* payload, unsigned int length);

// WiFi credentials 
const char* ssid = "realme";
const char* password = "12345678";

// MQTT Broker details
const char* mqtt_server = "5.196.78.28";
const char* mqtt_topic = "nodemcu/dht11";

// WiFi and MQTT client objects
WiFiClient espClient;
PubSubClient client(espClient);

DHT_Unified dht(DHTPIN, DHTTYPE);


uint32_t delayMS;
unsigned long lastPublishTime = 0;
// Time interval between last published 
const long publishInterval = 3000; // time is in ms we can change our wish
float moisturePercentage; // moisture persentage of 
bool pumpState = false; // state of the water pump

void setup() {
  Serial.begin(115200);
  delay(1000);

  // Connect to WiFi using wifi.begin
  // print the detail of the wifi
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Setup MQTT server 
  client.setServer(mqtt_server, 1883);
  
  // Setting last will message
  client.setCallback(callback);
  
  // Initialize DHT sensor
  dht.begin();

  // Get sensor minimum delay
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);
  delayMS = sensor.min_delay / 1000;

  // For testing purpose get built in led as relay to the motor
  pinMode(BUILTIN_LED, OUTPUT);

  // Initial connection to the server
  reconnect();
}

void loop() {
  checkWiFi();
  
  if (true) {
    publishSensorData();
  }
  
  // Maintain MQTT connection
  client.loop();  

  unsigned long now = millis();
  if (now - lastPublishTime >= publishInterval) {
    lastPublishTime = now;
    publishSensorData();
  }

  // check for the incoming message if the water pump state is True on the motor else off the motor
}

/*
function to publish the data to the server 
error can be seen by the serial monitor
if the error in publishing = Publish failed! MQTT State
if the error in reading it will print = Error reading sensor data!
*/
void publishSensorData() {
  // calculate the moisture sensor data
  moisturePercentage = ( 100.00 - ( (analogRead(MOISTUREPIN) / 1023.00) * 100.00 ) );

  // get the sensor events
  sensors_event_t tempEvent, humEvent;

  dht.temperature().getEvent(&tempEvent);
  dht.humidity().getEvent(&humEvent);

  // if the temperature and humidity set by the sensor 
  if (!isnan(tempEvent.temperature) && !isnan(humEvent.relative_humidity)) {
    String payload = "{\"temperature\": " + String(tempEvent.temperature) +
                     ", \"humidity\": " + String(humEvent.relative_humidity) +
                     ", \"moisture\": " + String(moisturePercentage) +
                     ", \"pumpState\": " + String(pumpState) + "}";


    if (client.connect("ESP8266Client", mqtt_topic, 1, true, payload.c_str())) {
      Serial.println("Published: " + payload);
    } else {
      Serial.println("Publish failed! MQTT State: " + String(client.state()));
    }
  } else {
    Serial.println("Error reading sensor data!");
  }
}

/*
this will initially connect with the mqtt sever and publish initial message
*/
void reconnect() {
  while (!client.connected()) {
    Serial.println("Attempting MQTT connection...");
    if (client.connect("ESP8266Client", mqtt_topic, 1, true, "connection message!")) {
      Serial.println("Connected to MQTT broker!");
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

/*
check for the wifi connection if it is disconnected it will again try to reconnect with 
ssid and password
it will continuously run until the  
*/
void checkWiFi() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected! Reconnecting...");
    WiFi.disconnect();
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      delay(1000);
      Serial.print(".");
    }
    Serial.println("\nWiFi Reconnected!");
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received on topic: ");
  Serial.println(topic);
}

/*
method to get the data from API
this method get the data from the whether api return
*/
void getWeatherForecast() {
  WiFiClient client;
  String path = "/v1/forecast.json?key=" + apiKey + "&q=" + location + "&days=1&aqi=no&alerts=no";

  if (client.connect("api.weatherapi.com", 80)) {
    client.print("GET " + path + " HTTP/1.1\r\n");
    client.print("Host: api.weatherapi.com\r\n");
    client.print("Connection: close\r\n\r\n");

    // Wait for response
    while (client.connected() && !client.available()) delay(1);

    // Skip HTTP headers
    while (client.connected() && client.readStringUntil('\n') != "\r");

    // Parse JSON
    DynamicJsonDocument doc(3072); // Adjust size based on response
    deserializeJson(doc, client);

    JsonObject forecast = doc["forecast"]["forecastday"][0];
    JsonArray hours = forecast["hour"];

    for (int i = 0; i < 5; i++) { // Next 5 hours
      String time = hours[i]["time"].as<String>();
      float temp = hours[i]["temp_c"].as<float>();
      Serial.printf("Time: %s, Temp: %.1f°C\n", time.c_str(), temp);
    }
  }
  client.stop();
}
