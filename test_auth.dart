import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akhhxegpljrzmkziirng.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFraGh4ZWdwbGpyem1remlpcm5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxNzE0NzksImV4cCI6MjA4OTc0NzQ3OX0.M5-oSPlXcfeHdY66q622RtrMDMl6sI9phGRlrQzaKnk',
  );

  print('Testing Login for testuser@vello.com (old user)...');
  try {
    final res = await supabase.auth.signInWithPassword(
      email: 'testuser@vello.com',
      password: 'Test@1234',
    );
    print('✅ Login SUCCESS! User ID: ${res.user?.id}');
  } on AuthException catch (e) {
    print('❌ Login failed: ${e.message}');
  } catch (e) {
    print('❌ Login error: $e');
  }

  print('\nTesting Signup for test3@vello.com...');
  try {
    final res = await supabase.auth.signUp(
      email: 'test4@vello.com',
      password: 'Test@1234',
    );
    print('✅ Signup SUCCESS! User ID: ${res.user?.id}');
    print('Is email confirmed? ${res.user?.emailConfirmedAt != null}');
  } on AuthException catch (e, st) {
    print('❌ Signup failed: ${e.message}');
    print(st);
  } catch (e, st) {
    print('❌ Signup error: $e');
    print(st);
  }
}

