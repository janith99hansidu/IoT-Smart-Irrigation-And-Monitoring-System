#include "Weather.h"
#include <ESP8266WiFi.h>
#include <Arduino.h>
#include <ArduinoJson.h>

// API credentials and location
const String apiKey = "b972377fa4ea414daa374853250502";
const String location = "Kilinochchi";

void getWeatherForecast() {
  WiFiClient client;
  String path = "/v1/current.json?key=" + apiKey + "&q=" + location;

  if (client.connect("api.weatherapi.com", 80)) {
    client.print("GET " + path + " HTTP/1.1\r\n");
    client.print("Host: api.weatherapi.com\r\n");
    client.print("Connection: close\r\n\r\n");

    // Wait for response
    while (client.connected() && !client.available()) delay(1);

    // Skip HTTP headers
    while (client.connected() && client.readStringUntil('\n') != "\r");

    // Parse JSON
    DynamicJsonDocument doc(3072); // Adjust size if necessary
    DeserializationError error = deserializeJson(doc, client);
    if (error) {
      Serial.print("deserializeJson() failed: ");
      Serial.println(error.f_str());
      return;
    }
  } else {
    Serial.println("Failed to connect to weather API");
  }
  client.stop();
}
