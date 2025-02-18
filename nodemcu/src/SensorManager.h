#ifndef SENSORMANAGER_H
#define SENSORMANAGER_H

#include <DHT.h>
#include <DHT_U.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// Publishes sensor data (temperature, humidity, moisture, pump state) over MQTT.
void publishSensorData(DHT_Unified &dht, float &moisturePercentage, bool &pumpState, 
                         PubSubClient &client, int moisturePin, const char* mqttTopic);

#endif // SENSORMANAGER_H
