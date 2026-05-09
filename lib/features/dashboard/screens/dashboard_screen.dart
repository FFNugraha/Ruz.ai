import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/services/iot_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  final IoTService _iotService = IoTService();
  SensorData? _sensorData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _setupIoT();
  }

  void _setupIoT() {
    _iotService.connect();
    _iotService.sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _sensorData = data;
        });
      }
    });
  }

  Future<void> _fetchWeather() async {
    final data = await _weatherService.getCurrentWeather();
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ruz.ai'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat pagi, Petani! 🌅',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamis, 28 April 2026',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildFieldStatusCard(),
            const SizedBox(height: 24),
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.camera_alt, 'Foto Daun', AppColors.primary),
                _buildQuickAction(Icons.chat, 'Tanya AI', AppColors.secondary),
                _buildQuickAction(Icons.history, 'Riwayat', AppColors.info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    String weatherDesc = 'Memuat...';
    String temp = '--°C';
    IconData iconData = Icons.cloud_outlined;

    if (!_isLoadingWeather && _weatherData != null) {
      weatherDesc = _weatherService.getWeatherDescription(_weatherData!.weatherCode);
      temp = '${_weatherData!.temperature.round()}°C';
      
      String iconStr = _weatherService.getWeatherIcon(_weatherData!.weatherCode);
      if (iconStr == 'wb_sunny') {
        iconData = Icons.wb_sunny;
      } else if (iconStr == 'cloud_queue') iconData = Icons.cloud_queue;
      else if (iconStr == 'foggy') iconData = Icons.foggy;
      else if (iconStr == 'grain') iconData = Icons.grain;
      else if (iconStr == 'water_drop') iconData = Icons.water_drop;
      else if (iconStr == 'flash_on') iconData = Icons.flash_on;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cuaca Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(weatherDesc, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              if (_isLoadingWeather)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(iconData, size: 40, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                temp,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFieldStatusCard() {
    final temp = _sensorData?.temperature.toStringAsFixed(1) ?? '--';
    final humidity = _sensorData?.humidity.toStringAsFixed(1) ?? '--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sawah Utama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  if (_sensorData != null)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                  const Icon(Icons.grass, color: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_sensorData == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSensorItem(Icons.thermostat, 'Suhu Udara', '$temp°C', AppColors.warning),
                _buildSensorItem(Icons.water_drop, 'Kelembapan', '$humidity%', AppColors.info),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSensorItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
