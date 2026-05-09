import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IoTService {
  final MqttServerClient client = MqttServerClient('9ee7dd76df1947aa9b4c775cd9673910.s1.eu.hivemq.cloud', '');
  final StreamController<SensorData> _sensorDataController = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  Future<void> connect() async {
    client.port = 8883;
    client.secure = true;
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
      await client.connect('ESP32CLIENT', 'Admin123');
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
      client.subscribe('iot/kebun/sensor', MqttQos.atLeastOnce);
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
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final String soilStatus;
  final DateTime lastUpdated;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilStatus,
    required this.lastUpdated,
  });

  factory SensorData.fromJson(Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SensorData(
      temperature: parseDouble(data['suhu']),
      humidity: parseDouble(data['kelembapan'] ?? data['kelembaban']),
      soilMoisture: parseDouble(data['soil_pct'] ?? data['soilpct']),
      soilStatus: data['soil_status']?.toString() ?? 'Unknown',
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
