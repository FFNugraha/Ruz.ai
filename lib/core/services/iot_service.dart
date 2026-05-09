import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IoTService {
  final MqttServerClient client = MqttServerClient('broker.emqx.io', '');
  final StreamController<SensorData> _sensorDataController = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  Future<void> connect() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier('ruzai_app_${DateTime.now().millisecondsSinceEpoch}')
        .withWillTopic('ruzai/field/sensors/status')
        .withWillMessage('offline')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        try {
          final data = json.decode(pt);
          _sensorDataController.add(SensorData.fromJson(data));
        } catch(e) {
          print('Error parsing IoT data: $e');
        }
      });
      client.subscribe('ruzai/field/sensors', MqttQos.atLeastOnce);
    } else {
      print('ERROR: MQTT client connection failed');
      client.disconnect();
    }
  }

  void onDisconnected() {
    print('MQTT client disconnected');
  }
}

class SensorData {
  final double soilMoisture;   // % kelembaban tanah
  final double temperature;    // °C suhu udara
  final double soilPH;         // pH tanah
  final DateTime lastUpdated;

  SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.soilPH,
    required this.lastUpdated,
  });

  factory SensorData.fromJson(Map<String, dynamic> data) {
    return SensorData(
      soilMoisture: (data['humidity'] ?? data['soil_moisture'] ?? 0).toDouble(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      soilPH: (data['soil_ph'] ?? 0).toDouble(),
      lastUpdated: DateTime.now(),
    );
  }

  bool get isMoistureOptimal => soilMoisture >= 65 && soilMoisture <= 85;
  bool get isTempOptimal => temperature >= 22 && temperature <= 32;

  String get moistureStatus {
    if (soilMoisture < 50) return '⚠️ Terlalu Kering - Segera Irigasi';
    if (soilMoisture > 90) return '⚠️ Terlalu Basah - Kurangi Air';
    return '✅ Normal';
  }
}
