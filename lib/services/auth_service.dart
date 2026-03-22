import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  // Use a getter so Supabase.instance is only accessed after initialize() completes
  SupabaseClient get _supabase => Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<AuthResponse> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // Create user profile in 'users' table
      if (response.user != null) {
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      // If table doesn't exist yet, return a basic model from auth
      final user = currentUser;
      if (user != null) {
        return UserModel(
          uid: user.id,
          name: user.userMetadata?['name'] ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        );
      }
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;

      await _supabase.from('users').update(updates).eq('id', uid);
    } catch (e) {
      rethrow;
    }
  }
}