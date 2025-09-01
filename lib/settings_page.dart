// lib/settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isCelsius;
  final VoidCallback onToggleUnit;

  const SettingsPage({
    super.key,
    required this.isCelsius,
    required this.onToggleUnit,
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
          child: Card(
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
        ),
      ),
    );
  }
}
