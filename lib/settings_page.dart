// lib/settings_page.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appName = 'SkyCast';
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.1),
                child: SwitchListTile(
                  title: const Text('Temperature Unit'),
                  subtitle: Text(widget.isCelsius ? 'Celsius' : 'Fahrenheit'),
                  value: widget.isCelsius,
                  onChanged: (bool value) {
                    widget.onToggleUnit();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                child: SwitchListTile(
                  title: const Text('Time Format'),
                  subtitle: Text(widget.is24HourFormat ? '24-Hour' : '12-Hour'),
                  value: widget.is24HourFormat,
                  onChanged: (bool value) {
                    widget.onToggleTimeFormat();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                child: ListTile(
                  title: const Text('App Info'),
                  subtitle: const Text('About SkyCast and licenses'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: _appName,
                      applicationVersion: _appVersion,
                      applicationIcon: Image.asset('assets/images/logo.png',
                          height: 48, width: 48),
                      applicationLegalese: '© 2025 SkyCast',
                    );
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
