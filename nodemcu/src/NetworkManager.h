#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// Connect to WiFi using the provided credentials.
void connectWiFi(const char* ssid, const char* password);

// Check and reconnect to WiFi if disconnected.
void checkWiFi(const char* ssid, const char* password);

// Setup the MQTT server and assign a callback.
void setupMQTT(PubSubClient &client, const char* mqtt_server, const char* mqtt_topic);

// Reconnect to the MQTT broker if disconnected.
void reconnectMQTT(PubSubClient &client, const char* mqtt_topic);

// MQTT callback function to process incoming messages.
void mqttCallback(char* topic, byte* payload, unsigned int length);

#endif // NETWORKMANAGER_H
