// weather_model.dart
import 'package:flutter/material.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

class Forecast {
  final DateTime timestamp;
  final double temperature;
  final String iconCode;

  Forecast({
    required this.timestamp,
    required this.temperature,
    required this.iconCode,
  });

  factory Forecast.fromJson(Map<String, dynamic> json,
      {required bool isHourly}) {
    return Forecast(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature:
          isHourly ? json['temp'].toDouble() : json['temp']['day'].toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }
}

class CurrentWeather {
  final Weather weather;
  final double latitude;
  final double longitude;

  CurrentWeather({
    required this.weather,
    required this.latitude,
    required this.longitude,
  });
}

class ForecastData {
  final List<Forecast> hourlyForecast;
  final List<Forecast> dailyForecast;

  ForecastData({
    required this.hourlyForecast,
    required this.dailyForecast,
  });
}
