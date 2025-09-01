// lib/main.dart
import 'package:flutter/material.dart';
import 'package:skycast/splash_screen.dart';
import 'package:skycast/weather_service.dart';
import 'package:skycast/weather_model.dart';
import 'package:skycast/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyCast',
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E212A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const WeatherAppLoader(),
    );
  }
}

class WeatherAppLoader extends StatefulWidget {
  const WeatherAppLoader({super.key});

  @override
  State<WeatherAppLoader> createState() => _WeatherAppLoaderState();
}

class _WeatherAppLoaderState extends State<WeatherAppLoader> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  List<Forecast>? _hourlyForecast;
  List<Forecast>? _dailyForecast;
  bool _isLoading = true;
  String _error = '';
  String _currentCity = '';
  bool _isCelsius = true;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final weatherData = await _weatherService.fetchWeatherByLocation();
      setState(() {
        _weather = weatherData.weather;
        _hourlyForecast = [];
        _dailyForecast = [];
        _currentCity = _weather!.cityName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch weather data. ($e)';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final weatherData = await _weatherService.fetchWeatherByCity(cityName);
      setState(() {
        _weather = weatherData.weather;
        _hourlyForecast = [];
        _dailyForecast = [];
        _currentCity = _weather!.cityName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to find city or fetch data. ($e)';
        _isLoading = false;
      });
    }
  }

  void _toggleUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
    });
  }

  double _convertTemperature(double temp) {
    return _isCelsius ? temp : (temp * 9 / 5) + 32;
  }

  String _getBackgroundAsset(String iconCode) {
    if (iconCode.contains('d')) {
      if (iconCode == '01d') return 'assets/backgrounds/sunny.jpg';
      if (iconCode.contains('02') ||
          iconCode.contains('03') ||
          iconCode.contains('04')) return 'assets/backgrounds/cloudy.jpg';
      if (iconCode.contains('09') ||
          iconCode.contains('10') ||
          iconCode.contains('11')) return 'assets/backgrounds/rainy.jpg';
      if (iconCode.contains('13')) return 'assets/backgrounds/snowy.jpg';
      if (iconCode.contains('50')) return 'assets/backgrounds/misty.jpg';
    } else {
      if (iconCode == '01n') return 'assets/backgrounds/night.jpg';
      if (iconCode.contains('02') ||
          iconCode.contains('03') ||
          iconCode.contains('04')) return 'assets/backgrounds/cloudy_night.jpg';
      if (iconCode.contains('09') ||
          iconCode.contains('10') ||
          iconCode.contains('11')) return 'assets/backgrounds/rainy_night.jpg';
      if (iconCode.contains('13')) return 'assets/backgrounds/snowy_night.jpg';
      if (iconCode.contains('50')) return 'assets/backgrounds/misty_night.jpg';
    }
    return 'assets/backgrounds/default.jpg';
  }

  // A helper function to format a Unix timestamp to a readable time.
  String _formatTime(int unixTimestamp, int timezoneOffset) {
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true);
    final localTime = dateTimeUtc.add(Duration(seconds: timezoneOffset));
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('SkyCast')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return WeatherHomePage(
      weather: _weather!,
      hourlyForecast: _hourlyForecast!,
      dailyForecast: _dailyForecast!,
      currentCity: _currentCity,
      isCelsius: _isCelsius,
      onToggleUnit: _toggleUnit,
      onFetchByLocation: _fetchWeatherByLocation,
      onFetchByCity: _fetchWeatherByCity,
      convertTemperature: _convertTemperature,
      getBackgroundAsset: _getBackgroundAsset,
      formatTime: _formatTime, // Pass the new helper function
    );
  }
}

class WeatherHomePage extends StatelessWidget {
  final Weather weather;
  final List<Forecast> hourlyForecast;
  final List<Forecast> dailyForecast;
  final String currentCity;
  final bool isCelsius;
  final VoidCallback onToggleUnit;
  final VoidCallback onFetchByLocation;
  final Function(String) onFetchByCity;
  final Function(double) convertTemperature;
  final Function(String) getBackgroundAsset;
  final Function(int, int) formatTime;

  const WeatherHomePage({
    super.key,
    required this.weather,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.currentCity,
    required this.isCelsius,
    required this.onToggleUnit,
    required this.onFetchByLocation,
    required this.onFetchByCity,
    required this.convertTemperature,
    required this.getBackgroundAsset,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          currentCity,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: onFetchByLocation,
          ),
          IconButton(
            icon:
                Icon(isCelsius ? Icons.thermostat : Icons.thermostat_outlined),
            onPressed: onToggleUnit,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(getBackgroundAsset(weather.iconCode)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white70),
                          onPressed: () {
                            if (cityController.text.isNotEmpty) {
                              onFetchByCity(cityController.text);
                            }
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          onFetchByCity(value);
                        }
                      },
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${convertTemperature(weather.temperature).round()}°${isCelsius ? 'C' : 'F'}',
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.description,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Local Time: ${formatTime(weather.dt, weather.timezoneOffset)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                        scale: 0.5,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.wb_sunny, size: 120),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.wb_sunny,
                                size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            const Text('Sunrise',
                                style: TextStyle(color: Colors.white70)),
                            Text(
                              formatTime(
                                  weather.sunrise, weather.timezoneOffset),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.nights_stay,
                                size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            const Text('Sunset',
                                style: TextStyle(color: Colors.white70)),
                            Text(
                              formatTime(
                                  weather.sunset, weather.timezoneOffset),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Hourly and daily forecast sections are now here
                  if (hourlyForecast.isNotEmpty)
                    _buildForecastSection(
                      title: 'Hourly Forecast',
                      forecastList: hourlyForecast,
                      isHourly: true,
                    ),
                  const SizedBox(height: 24),
                  if (dailyForecast.isNotEmpty)
                    _buildForecastSection(
                      title: 'Daily Forecast',
                      forecastList: dailyForecast,
                      isHourly: false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection({
    required String title,
    required List<Forecast> forecastList,
    required bool isHourly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: isHourly ? 120 : 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: isHourly ? 8 : 7,
            itemBuilder: (context, index) {
              final forecast = forecastList[index];
              return _buildForecastCard(forecast, isHourly);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(Forecast forecast, bool isHourly) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isHourly
                  ? '${forecast.timestamp.hour.toString().padLeft(2, '0')}:00'
                  : '${forecast.timestamp.day.toString().padLeft(2, '0')}/${forecast.timestamp.month.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Image.network(
              'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.wb_sunny, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              '${convertTemperature(forecast.temperature).round()}°${isCelsius ? 'C' : 'F'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
