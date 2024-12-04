#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>

// Pin untuk sensor DHT22
#define DHTPIN 4
DHT dht(DHTPIN, DHT22);

// Pin untuk sensor arus dan tegangan
#define CURRENT_SENSOR_PIN A0
#define VOLTAGE_SENSOR_PIN A1

// WiFi Credentials
const char* ssid = "your-SSID";
const char* password = "your-PASSWORD";

// URL server
const char* serverURL = "http://your-server.com/ev-charging-status";

class EVChargingSystem {
public:
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
        return voltage / 0.185; // Konversi arus
    }

    float readVoltage() {
        int sensorValue = analogRead(VOLTAGE_SENSOR_PIN);
        return sensorValue * (5.0 / 1023.0); // Konversi tegangan
    }

    float readTemperature() {
        return dht.readTemperature(); // Baca suhu
    }

    void sendDataToServer(float current, float voltage, float temperature) {
        HTTPClient http;
        http.begin(serverURL);
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
};

EVChargingSystem evSystem;

void setup() {
    evSystem.setup();
}

void loop() {
    float current = evSystem.readCurrent();
    float voltage = evSystem.readVoltage();
    float temperature = evSystem.readTemperature();

    Serial.print("Current: ");
    Serial.print(current);
    Serial.print(" A, Voltage: ");
    Serial.print(voltage);
    Serial.print(" V, Temperature: ");
    Serial.print(temperature);
    Serial.println(" C");

    evSystem.sendDataToServer(current, voltage, temperature);

    delay(60000); // Kirim data setiap 60 detik
}
