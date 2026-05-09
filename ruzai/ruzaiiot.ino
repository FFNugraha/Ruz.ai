
#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// ─── WiFi ─────────────────────────────────────────────────
const char* ssid     = "RUANG_BELAJAR";
const char* password = "bismillah";

// ─── MQTT Broker ──────────────────────────────────────────
const char* mqtt_server = "broker.hivemq.com";
const int   mqtt_port   = 1883;
const char* mqtt_client_id = "ESP32_SoilDHT_001"; 

// ─── MQTT Topics ──────────────────────────────────────────
const char* topic_sensor = "iot/kebun/sensor";      
const char* topic_status = "iot/kebun/status";      

// ─── Pin Definition ───────────────────────────────────────
#define DHT_PIN      4      
#define DHT_TYPE     DHT11
#define SOIL_PIN     34     
#define LED_PIN      2     

// ─── Kalibrasi Soil Sensor ────────────────────────────────
const int SOIL_DRY = 3500;
const int SOIL_WET = 1200;

// ─── Interval Publish (ms) ────────────────────────────────
const long PUBLISH_INTERVAL = 5000;   

// ─── Objek ────────────────────────────────────────────────
DHT dht(DHT_PIN, DHT_TYPE);
WiFiClient espClient;
PubSubClient mqttClient(espClient);

unsigned long lastPublish = 0;

// ──────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);

  dht.begin();
  setupWiFi();

  mqttClient.setServer(mqtt_server, mqtt_port);
  mqttClient.setCallback(mqttCallback);
  mqttClient.setKeepAlive(60);
}

// ──────────────────────────────────────────────────────────
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

// ──────────────────────────────────────────────────────────
void setupWiFi() {
  Serial.print("\n[WiFi] Menghubungkan ke ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  int attempt = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_PIN, !digitalRead(LED_PIN));  // blink
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

// ──────────────────────────────────────────────────────────
void reconnectMQTT() {
  while (!mqttClient.connected()) {
    Serial.print("[MQTT] Menghubungkan ke broker...");

    // LWT (Last Will Testament) — kirim offline jika putus
    String willMsg = "{\"status\":\"offline\",\"device\":\"" + String(mqtt_client_id) + "\"}";

    if (mqttClient.connect(
          mqtt_client_id,
          nullptr, nullptr,
          topic_status, 0, true, willMsg.c_str()
        )) {
      Serial.println(" Terhubung!");

      // Publish status online
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

// ──────────────────────────────────────────────────────────
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  // Untuk pengembangan selanjutnya (subscribe perintah dari server)
  Serial.print("[MQTT] Pesan masuk [");
  Serial.print(topic);
  Serial.print("]: ");
  for (unsigned int i = 0; i < length; i++) Serial.print((char)payload[i]);
  Serial.println();
}

// ──────────────────────────────────────────────────────────
void publishSensorData() {
  // ── Baca DHT11 ──
  float suhu      = dht.readTemperature();
  float kelembapan = dht.readHumidity();

  if (isnan(suhu) || isnan(kelembapan)) {
    Serial.println("[DHT11] Gagal membaca sensor!");
    return;
  }

  // ── Baca Soil Moisture ──
  int soilRaw = analogRead(SOIL_PIN);
  // Konversi ke persentase (0% = kering, 100% = basah)
  int soilPct = map(soilRaw, SOIL_DRY, SOIL_WET, 0, 100);
  soilPct = constrain(soilPct, 0, 100);

  // ── Tentukan status tanah ──
  String soilStatus;
  if      (soilPct < 20)  soilStatus = "Sangat Kering";
  else if (soilPct < 40)  soilStatus = "Kering";
  else if (soilPct < 65)  soilStatus = "Optimal";
  else if (soilPct < 85)  soilStatus = "Lembap";
  else                    soilStatus = "Terlalu Basah";

  // ── Hitung Heat Index ──
  float heatIndex = dht.computeHeatIndex(suhu, kelembapan, false);

  // ── Buat JSON payload ──
  StaticJsonDocument<256> doc;
  doc["device"]        = mqtt_client_id;
  doc["suhu"]          = round(suhu * 10) / 10.0;
  doc["kelembapan"]    = round(kelembapan * 10) / 10.0;
  doc["heat_index"]    = round(heatIndex * 10) / 10.0;
  doc["soil_raw"]      = soilRaw;
  doc["soil_pct"]      = soilPct;
  doc["soil_status"]   = soilStatus;
  doc["timestamp"]     = millis();

  char payload[256];
  serializeJson(doc, payload);

  // ── Publish ──
  if (mqttClient.publish(topic_sensor, payload)) {
    Serial.println("[MQTT] Data terkirim:");
    Serial.println(payload);
  } else {
    Serial.println("[MQTT] Gagal mengirim data!");
  }

  // Blink LED tanda sukses kirim
  digitalWrite(LED_PIN, LOW);
  delay(100);
  digitalWrite(LED_PIN, HIGH);
}
