import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _smsEmailBills = true;
  bool _smsBills = true;
  bool _budgetAlerts = true;
  bool _weeklySummary = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF03724E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF03724E)),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _isDarkMode,
            onChanged: (val) {
              setState(() {
                _isDarkMode = val;
              });
            },
          ),
          ListTile(
            title: const Text('Language'),
            leading: const Icon(Icons.language),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: <String>['English', 'Spanish', 'French', 'German'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedLanguage = val;
                  });
                }
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Auto Bill Detection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF03724E)),
            ),
          ),
          SwitchListTile(
            title: const Text('SMS and Email Bills'),
            secondary: const Icon(Icons.email_outlined),
            value: _smsEmailBills,
            onChanged: (val) {
              setState(() {
                _smsEmailBills = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text('SMS Bills Only'),
            secondary: const Icon(Icons.sms_outlined),
            value: _smsBills,
            onChanged: (val) {
              setState(() {
                _smsBills = val;
              });
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF03724E)),
            ),
          ),
          SwitchListTile(
            title: const Text('Budget Alerts'),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: _budgetAlerts,
            onChanged: (val) {
              setState(() {
                _budgetAlerts = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Weekly Summary'),
            secondary: const Icon(Icons.summarize_outlined),
            value: _weeklySummary,
            onChanged: (val) {
              setState(() {
                _weeklySummary = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
