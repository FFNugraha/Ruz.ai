/*
 * ============================================================
 *  IoT Monitoring - Soil Moisture + DHT11 via MQTT
 *  Hardware : ESP32
 *  Sensors  : DHT11 (suhu & kelembapan udara)
 *             Soil Moisture Sensor (kelembapan tanah)
 *  Protokol : MQTT over TLS (HiveMQ Cloud port 8883)
 * ============================================================
 *
 *  Library yang dibutuhkan (install via Library Manager):
 *    - DHT sensor library by Adafruit
 *    - Adafruit Unified Sensor
 *    - PubSubClient by Nick O'Leary
 *    - ArduinoJson by Benoit Blanchon
 *
 *  Wiring:
 *    DHT11  -> GPIO 27
 *    Soil   -> GPIO 34 (ADC)
 *    LED    -> GPIO 2  (built-in, opsional)
 * ============================================================
 */

#include <WiFi.h>
#include <WiFiClientSecure.h>   // ✅ FIX: ganti dari WiFiClient
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// ─── WiFi ────────────────────────────────────────────────────
const char* ssid     = "RUANG_BELAJAR";
const char* password = "bismillah";

// ─── MQTT Broker ─────────────────────────────────────────────
const char* mqtt_server    = "9ee7dd76df1947aa9b4c775cd9673910.s1.eu.hivemq.cloud";
const int   mqtt_port      = 8883;
const char* mqtt_client_id = "ESP32_SoilDHT_001";
const char* mqtt_user      = "ESP32CLIENT";
const char* mqtt_pass      = "Admin123";

// ─── MQTT Topics ─────────────────────────────────────────────
const char* topic_sensor = "iot/kebun/sensor";
const char* topic_status = "iot/kebun/status";

// ─── Pin Definition ──────────────────────────────────────────
#define DHT_PIN   27
#define DHT_TYPE  DHT11
#define SOIL_PIN  34
#define LED_PIN   2

// ─── Kalibrasi Soil Sensor ───────────────────────────────────
const int SOIL_DRY = 3500;
const int SOIL_WET = 1200;

// ─── Interval Publish (ms) ───────────────────────────────────
const long PUBLISH_INTERVAL = 5000;

// ─── Objek ───────────────────────────────────────────────────
DHT dht(DHT_PIN, DHT_TYPE);
WiFiClientSecure espClient;       
PubSubClient mqttClient(espClient);

unsigned long lastPublish = 0;

// ─────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);

  dht.begin();
  setupWiFi();

  espClient.setInsecure();        // ✅ FIX: izinkan TLS tanpa CA cert

  mqttClient.setServer(mqtt_server, mqtt_port);
  mqttClient.setCallback(mqttCallback);
  mqttClient.setKeepAlive(60);
  mqttClient.setBufferSize(512);  // ✅ Tambahan: cegah payload terpotong
}

// ─────────────────────────────────────────────────────────────
void loop() {
  if (!mqttClient.connected()) {
    reconnectMQTT();
  }
  mqttClient.loop();

  unsigned long now = millis();
  if (now - lastPublish >= PUBLISH_INTERVAL) {
    lastPublish = now;
    publishSensorData();
  }
}

// ─────────────────────────────────────────────────────────────
void setupWiFi() {
  Serial.print("\n[WiFi] Menghubungkan ke ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  int attempt = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_PIN, !digitalRead(LED_PIN));
    if (++attempt > 40) {
      Serial.println("\n[WiFi] Gagal konek. Restart...");
      ESP.restart();
    }
  }

  digitalWrite(LED_PIN, HIGH);
  Serial.println("\n[WiFi] Terhubung!");
  Serial.print("[WiFi] IP Address: ");
  Serial.println(WiFi.localIP());
}

// ─────────────────────────────────────────────────────────────
void reconnectMQTT() {
  while (!mqttClient.connected()) {
    Serial.print("[MQTT] Menghubungkan ke broker...");

    String willMsg = "{\"status\":\"offline\",\"device\":\"" + String(mqtt_client_id) + "\"}";

    if (mqttClient.connect(
          mqtt_client_id,
          mqtt_user, mqtt_pass,   // ✅ FIX: ganti dari nullptr, nullptr
          topic_status, 0, true, willMsg.c_str()
        )) {
      Serial.println(" Terhubung!");

      String onlineMsg = "{\"status\":\"online\",\"device\":\"" + String(mqtt_client_id) + "\"}";
      mqttClient.publish(topic_status, onlineMsg.c_str(), true);

    } else {
      Serial.print(" Gagal, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" — Coba lagi 5 detik...");
      delay(5000);
    }
  }
}

// ─────────────────────────────────────────────────────────────
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("[MQTT] Pesan masuk [");
  Serial.print(topic);
  Serial.print("]: ");
  for (unsigned int i = 0; i < length; i++) Serial.print((char)payload[i]);
  Serial.println();
}

// ─────────────────────────────────────────────────────────────
void publishSensorData() {
  // ── Baca DHT11 ──
  float suhu       = dht.readTemperature();
  float kelembapan = dht.readHumidity();

  if (isnan(suhu) || isnan(kelembapan)) {
    Serial.println("[DHT11] Gagal membaca sensor!");
    return;
  }

  // ── Baca Soil Moisture ──
  int soilRaw = analogRead(SOIL_PIN);
  int soilPct = map(soilRaw, SOIL_DRY, SOIL_WET, 0, 100);
  soilPct = constrain(soilPct, 0, 100);

  // ── Status tanah ──
  String soilStatus;
  if      (soilPct < 20) soilStatus = "Sangat Kering";
  else if (soilPct < 40) soilStatus = "Kering";
  else if (soilPct < 65) soilStatus = "Optimal";
  else if (soilPct < 85) soilStatus = "Lembap";
  else                   soilStatus = "Terlalu Basah";

  // ── Heat Index ──
  float heatIndex = dht.computeHeatIndex(suhu, kelembapan, false);

  // ── JSON Payload ──
  StaticJsonDocument<256> doc;
  doc["device"]      = mqtt_client_id;
  doc["suhu"]        = round(suhu * 10) / 10.0;
  doc["kelembapan"]  = round(kelembapan * 10) / 10.0;
  doc["heat_index"]  = round(heatIndex * 10) / 10.0;
  doc["soil_raw"]    = soilRaw;
  doc["soil_pct"]    = soilPct;
  doc["soil_status"] = soilStatus;
  doc["timestamp"]   = millis();

  char payload[256];
  serializeJson(doc, payload);

  // ── Publish ──
  if (mqttClient.publish(topic_sensor, payload)) {
    Serial.println("[MQTT] Data terkirim:");
    Serial.println(payload);
  } else {
    Serial.println("[MQTT] Gagal mengirim data!");
  }

  // Blink LED
  digitalWrite(LED_PIN, LOW);
  delay(100);
  digitalWrite(LED_PIN, HIGH);
}