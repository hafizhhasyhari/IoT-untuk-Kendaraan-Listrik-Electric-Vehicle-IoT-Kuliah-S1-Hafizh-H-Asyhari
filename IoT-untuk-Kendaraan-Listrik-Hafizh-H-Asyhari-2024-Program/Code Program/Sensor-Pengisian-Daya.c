// Sensor Pengisian Daya dengan C
// Dibuat oleh : Hafizh Hilman Asyhari
// 2024
#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>

// Pin untuk sensor DHT22 (suhu dan kelembapan)
#define DHTPIN 4
DHT dht(DHTPIN, DHT22);

// Pin untuk sensor arus dan tegangan
#define CURRENT_SENSOR_PIN A0
#define VOLTAGE_SENSOR_PIN A1

// WiFi Credentials
const char* ssid = "your-SSID";
const char* password = "your-PASSWORD";

// URL server untuk mengirim data
const char* serverURL = "http://your-server.com/ev-charging-status";

// Inisialisasi WiFi
void setup() {
  Serial.begin(115200);
  dht.begin();
  
  // Koneksi ke WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

float readCurrent() {
  int sensorValue = analogRead(CURRENT_SENSOR_PIN);
  float voltage = sensorValue * (5.0 / 1023.0);
  float current = voltage / 0.185; // Misalnya 0.185 untuk sensor arus tertentu
  return current;
}

float readVoltage() {
  int sensorValue = analogRead(VOLTAGE_SENSOR_PIN);
  float voltage = sensorValue * (5.0 / 1023.0);
  return voltage;
}

float readTemperature() {
  float temperature = dht.readTemperature();
  return temperature;
}

void sendDataToServer(float current, float voltage, float temperature) {
  HTTPClient http;
  http.begin(serverURL); // URL server
  http.addHeader("Content-Type", "application/json");

  String jsonPayload = "{\"current\": " + String(current) +
                       ", \"voltage\": " + String(voltage) +
                       ", \"temperature\": " + String(temperature) + "}";

  int httpResponseCode = http.POST(jsonPayload);

  if (httpResponseCode > 0) {
    Serial.println("Data sent successfully");
  } else {
    Serial.println("Error sending data");
  }
  http.end();
}

void loop() {
  float current = readCurrent();
  float voltage = readVoltage();
  float temperature = readTemperature();

  Serial.print("Current: ");
  Serial.print(current);
  Serial.print(" A, Voltage: ");
  Serial.print(voltage);
  Serial.print(" V, Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");

  sendDataToServer(current, voltage, temperature);

  delay(60000); // Kirim data setiap 60 detik
}
