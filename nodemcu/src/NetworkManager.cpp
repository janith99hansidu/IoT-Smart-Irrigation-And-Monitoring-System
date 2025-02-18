#include "NetworkManager.h"
#include <Arduino.h>

void connectWiFi(const char* ssid, const char* password) {
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
}

void checkWiFi(const char* ssid, const char* password) {
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

void setupMQTT(PubSubClient &client, const char* mqtt_server, const char* mqtt_topic) {
  client.setServer(mqtt_server, 1883);
  client.setCallback(mqttCallback);
}

void reconnectMQTT(PubSubClient &client, const char* mqtt_topic) {
  while (!client.connected()) {
    Serial.println("Attempting MQTT connection...");
    // Attempt to connect with a last will message ("connection message!")
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

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received on topic: ");
  Serial.println(topic);
  // (Optional) Process payload here if needed.
}
