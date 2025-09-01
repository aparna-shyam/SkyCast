// lib/main.dart

import 'package:flutter/material.dart';
import 'package:skycast/weather_service.dart';
import 'package:skycast/weather_model.dart';
import 'package:skycast/settings_page.dart';
import 'package:skycast/search_history_service.dart';
import 'dart:async';

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
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final WeatherService _weatherService = WeatherService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  Weather? _weather;
  List<Forecast>? _hourlyForecast;
  List<Forecast>? _dailyForecast;
  bool _isLoading = true;
  String _error = '';
  String _currentCity = '';
  bool _isCelsius = true;
  bool _is24HourFormat = true;
  List<String> _searchHistory = [];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
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
      _searchHistoryService.saveSearchHistory(_currentCity);
      _loadSearchHistory();
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
      _searchHistoryService.saveSearchHistory(_currentCity);
      _loadSearchHistory();
    } catch (e) {
      setState(() {
        _error = 'Failed to find city "$cityName". Please check the spelling.';
        _isLoading = false;
      });
    }
  }

  void _toggleUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
    });
  }

  void _toggleTimeFormat() {
    setState(() {
      _is24HourFormat = !_is24HourFormat;
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

  String _formatTime(int unixTimestamp, int timezoneOffset) {
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true);
    final localTime = dateTimeUtc.add(Duration(seconds: timezoneOffset));
    if (_is24HourFormat) {
      return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = localTime.hour > 12 ? localTime.hour - 12 : localTime.hour;
      final ampm = localTime.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} $ampm';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WeatherHomePage(
        weather: _weather,
        hourlyForecast: _hourlyForecast ?? [],
        dailyForecast: _dailyForecast ?? [],
        currentCity: _currentCity,
        isCelsius: _isCelsius,
        is24HourFormat: _is24HourFormat,
        onToggleUnit: _toggleUnit,
        onToggleTimeFormat: _toggleTimeFormat,
        onFetchByLocation: _fetchWeatherByLocation,
        onFetchByCity: _fetchWeatherByCity,
        convertTemperature: _convertTemperature,
        getBackgroundAsset: _getBackgroundAsset,
        formatTime: _formatTime,
        searchHistory: _searchHistory,
        onSelectCityFromHistory: (city) {
          _fetchWeatherByCity(city);
        },
      ),
      SettingsPage(
        isCelsius: _isCelsius,
        onToggleUnit: _toggleUnit,
        is24HourFormat: _is24HourFormat,
        onToggleTimeFormat: _toggleTimeFormat,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF2C3240),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class WeatherHomePage extends StatelessWidget {
  final Weather? weather;
  final List<Forecast> hourlyForecast;
  final List<Forecast> dailyForecast;
  final String currentCity;
  final bool isCelsius;
  final bool is24HourFormat;
  final VoidCallback onToggleUnit;
  final VoidCallback onToggleTimeFormat;
  final VoidCallback onFetchByLocation;
  final Function(String) onFetchByCity;
  final Function(double) convertTemperature;
  final Function(String) getBackgroundAsset;
  final Function(int, int) formatTime;
  final List<String> searchHistory;
  final Function(String) onSelectCityFromHistory;

  const WeatherHomePage({
    super.key,
    required this.weather,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.currentCity,
    required this.isCelsius,
    required this.is24HourFormat,
    required this.onToggleUnit,
    required this.onToggleTimeFormat,
    required this.onFetchByLocation,
    required this.onFetchByCity,
    required this.convertTemperature,
    required this.getBackgroundAsset,
    required this.formatTime,
    required this.searchHistory,
    required this.onSelectCityFromHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

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
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Search History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: searchHistory.length,
                            itemBuilder: (context, index) {
                              final city = searchHistory[index];
                              return ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text(city),
                                onTap: () {
                                  onSelectCityFromHistory(city);
                                  Navigator.pop(
                                      context); // Close the bottom sheet
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(getBackgroundAsset(weather!.iconCode)),
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
                        '${convertTemperature(weather!.temperature).round()}°${isCelsius ? 'C' : 'F'}',
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather!.description,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Local Time: ${formatTime(weather!.dt, weather!.timezoneOffset)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${weather!.iconCode}@4x.png',
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
                                  weather!.sunrise, weather!.timezoneOffset),
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
                                  weather!.sunset, weather!.timezoneOffset),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Conditions',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetric(
                                  icon: Icons.thermostat_auto,
                                  label: 'Feels Like',
                                  value:
                                      '${convertTemperature(weather!.feelsLike).round()}°${isCelsius ? 'C' : 'F'}'),
                              _buildMetric(
                                  icon: Icons.air,
                                  label: 'Wind',
                                  value: '${weather!.windSpeed.round()} m/s'),
                              _buildMetric(
                                  icon: Icons.water_drop,
                                  label: 'Humidity',
                                  value: '${weather!.humidity}%'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetric(
                                  icon: Icons.compress,
                                  label: 'Pressure',
                                  value: '${weather!.pressure} hPa'),
                              _buildMetric(
                                  icon: Icons.visibility,
                                  label: 'Visibility',
                                  value:
                                      '${(weather!.visibility / 1000).round()} km'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildMetric(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.white70),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
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
