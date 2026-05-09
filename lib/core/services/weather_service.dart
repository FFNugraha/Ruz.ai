import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Default coordinates (Jakarta, Indonesia) - can be updated with GPS later
  static const double defaultLat = -6.2088;
  static const double defaultLon = 106.8456;

  Future<WeatherData?> getCurrentWeather({double? lat, double? lon}) async {
    final latitude = lat ?? defaultLat;
    final longitude = lon ?? defaultLon;

    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code&timezone=Asia%2FJakarta');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        return WeatherData(
          temperature: current['temperature_2m'].toDouble(),
          weatherCode: current['weather_code'],
        );
      } else {
        print('Failed to load weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Cerah Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 80:
      case 81:
      case 82:
        return 'Hujan Lebat';
      case 95:
      case 96:
      case 99:
        return 'Badai Petir';
      default:
        return 'Tidak Diketahui';
    }
  }

  String getWeatherIcon(int code) {
    // Return material icon string representation or just a status
    switch (code) {
      case 0:
        return 'wb_sunny'; // Clear sky
      case 1:
      case 2:
      case 3:
        return 'cloud_queue'; // Partly cloudy
      case 45:
      case 48:
        return 'foggy'; // Fog
      case 51:
      case 53:
      case 55:
        return 'grain'; // Drizzle
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'water_drop'; // Rain
      case 95:
      case 96:
      case 99:
        return 'flash_on'; // Thunderstorm
      default:
        return 'cloud';
    }
  }
}

class WeatherData {
  final double temperature;
  final int weatherCode;

  WeatherData({required this.temperature, required this.weatherCode});
}
