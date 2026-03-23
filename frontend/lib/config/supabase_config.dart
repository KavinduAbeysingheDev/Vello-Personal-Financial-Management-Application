import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://akhhxegpljrzmkziirng.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFraGh4ZWdwbGpyem1remlpcm5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxNzE0NzksImV4cCI6MjA4OTc0NzQ3OX0.M5-oSPlXcfeHdY66q622RtrMDMl6sI9phGRlrQzaKnk';
}
