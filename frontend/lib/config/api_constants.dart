import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Use http://10.0.2.2:8000 for Android Emulator to access localhost
  // Use http://localhost:8000 for iOS Simulator or Web
  static String get baseUrl => dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:8000';
  static const String ruleAiEndpoint = '/api/v1/rule-ai/weekly-budget';
}
