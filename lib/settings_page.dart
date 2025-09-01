// lib/settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isCelsius;
  final bool is24HourFormat;
  final VoidCallback onToggleUnit;
  final VoidCallback onToggleTimeFormat;

  const SettingsPage({
    super.key,
    required this.isCelsius,
    required this.is24HourFormat,
    required this.onToggleUnit,
    required this.onToggleTimeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.1),
                child: SwitchListTile(
                  title: const Text('Temperature Unit'),
                  subtitle: Text(isCelsius ? 'Celsius' : 'Fahrenheit'),
                  value: isCelsius,
                  onChanged: (bool value) {
                    onToggleUnit();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                child: SwitchListTile(
                  title: const Text('Time Format'),
                  subtitle: Text(is24HourFormat ? '24-Hour' : '12-Hour'),
                  value: is24HourFormat,
                  onChanged: (bool value) {
                    onToggleTimeFormat();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
