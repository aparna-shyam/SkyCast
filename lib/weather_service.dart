// lib/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:skycast/config.dart'; // Import your secure API key
import 'package:skycast/weather_model.dart'; // Import the data models

// Weather service class
class WeatherService {
  final String _apiKey = openWeatherAPIKey;

  Future<CurrentWeather> fetchWeatherByLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    return await _fetchWeather(
        'lat=${position.latitude}&lon=${position.longitude}');
  }

  Future<CurrentWeather> fetchWeatherByCity(String cityName) async {
    return await _fetchWeather('q=$cityName');
  }

  Future<CurrentWeather> _fetchWeather(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?$query&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CurrentWeather(
        weather: Weather.fromJson(data),
        latitude: data['coord']['lat'],
        longitude: data['coord']['lon'],
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // NOTE: These methods are commented out because new free API keys
  // do not have access to the One Call API 3.0 by default.

  /*
  Future<ForecastData> fetchForecastByLocation(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ForecastData(
        hourlyForecast: (data['hourly'] as List)
            .map((item) => Forecast.fromJson(item, isHourly: true))
            .toList(),
        dailyForecast: (data['daily'] as List)
            .map((item) => Forecast.fromJson(item, isHourly: false))
            .toList(),
      );
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
  */
}
