import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'English'; // Default
  bool _emailBills = false;
  bool _smsBills = false;
  bool _budgetAlerts = true;
  bool _weeklySummary = true;
  bool _biometric = false;
  bool _twoFactor = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get emailBills => _emailBills;
  bool get smsBills => _smsBills;
  bool get budgetAlerts => _budgetAlerts;
  bool get weeklySummary => _weeklySummary;
  bool get biometric => _biometric;
  bool get twoFactor => _twoFactor;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language = prefs.getString('language') ?? 'English';
    _emailBills = prefs.getBool('emailBills') ?? false;
    _smsBills = prefs.getBool('smsBills') ?? false;
    _budgetAlerts = prefs.getBool('budgetAlerts') ?? true;
    _weeklySummary = prefs.getBool('weeklySummary') ?? true;
    _biometric = prefs.getBool('biometric') ?? false;
    _twoFactor = prefs.getBool('twoFactor') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }

  Future<void> setEmailBills(bool value) async {
    _emailBills = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailBills', value);
    notifyListeners();
  }

  Future<void> setSmsBills(bool value) async {
    _smsBills = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smsBills', value);
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool value) async {
    _budgetAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetAlerts', value);
    notifyListeners();
  }

  Future<void> setWeeklySummary(bool value) async {
    _weeklySummary = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklySummary', value);
    notifyListeners();
  }

  Future<void> setBiometric(bool value) async {
    _biometric = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', value);
    notifyListeners();
  }

  Future<void> setTwoFactor(bool value) async {
    _twoFactor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('twoFactor', value);
    notifyListeners();
  }
}



