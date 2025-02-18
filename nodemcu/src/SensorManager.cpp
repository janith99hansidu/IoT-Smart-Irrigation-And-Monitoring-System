#include "SensorManager.h"
#include <Arduino.h>
#include <math.h>
#include <ArduinoJson.h>

void publishSensorData(DHT_Unified &dht, float &moisturePercentage, bool &pumpState, 
                         PubSubClient &client, int moisturePin, const char* mqttTopic) {
  // Read the moisture sensor value and calculate the percentage
  int sensorValue = analogRead(moisturePin);
  moisturePercentage = 100.0 - ((sensorValue / 1023.0) * 100.0);
  
  // Retrieve temperature and humidity events
  sensors_event_t tempEvent, humEvent;
  dht.temperature().getEvent(&tempEvent);
  dht.humidity().getEvent(&humEvent);

  // Check if readings are valid
  if (!isnan(tempEvent.temperature) && !isnan(humEvent.relative_humidity)) {
    String payload = "{\"temperature\": " + String(tempEvent.temperature) +
                     ", \"humidity\": " + String(humEvent.relative_humidity) +
                     ", \"moisture\": " + String(moisturePercentage) +
                     ", \"pumpState\": " + String(pumpState) + "}";
                     
    // Connect (with last will message) and publish the payload
    if (client.connect("ESP8266Client", mqttTopic, 1, true, payload.c_str())) {
      Serial.println("Published: " + payload);
    } else {
      Serial.println("Publish failed! MQTT State: " + String(client.state()));
    }
  } else {
    Serial.println("Error reading sensor data!");
  }
}
