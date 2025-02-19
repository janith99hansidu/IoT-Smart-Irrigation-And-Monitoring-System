#include "FirestoreManager.h"
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>

// Replace with your Firestore project details.
const char* FIRESTORE_URL = "https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/YOUR_COLLECTION";

void pushDataToFirestore(String jsonPayload) {
  WiFiClientSecure client;
  client.setInsecure(); // For testing only—verify certificates in production
  
  HTTPClient https;
  
  Serial.println("Connecting to Firestore...");
  if (https.begin(client, FIRESTORE_URL)) {
    https.addHeader("Content-Type", "application/json");
    
    int httpResponseCode = https.POST(jsonPayload);
    
    if (httpResponseCode > 0) {
      String response = https.getString();
      Serial.print("Firestore response code: ");
      Serial.println(httpResponseCode);
      Serial.println("Response:");
      Serial.println(response);
    } else {
      Serial.print("Error posting to Firestore: ");
      Serial.println(https.errorToString(httpResponseCode));
    }
    
    https.end();
  } else {
    Serial.println("Failed to connect to Firestore");
  }
}
