// lib/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // 🔑 Your API key
  static const String apiKey = '76ffcc7d3ff9f200bcb585de980928f4';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to fetch weather: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}
