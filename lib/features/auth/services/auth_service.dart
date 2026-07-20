import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;

  // Login Method
  Future<String> login({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) throw 'Login failed.';

      // Fetch user role from profiles table
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', response.user!.id)
          .single();

      return profile['role'] as String; // Returns 'admin', 'seller', or 'customer'
    } catch (e) {
      throw e.toString();
    }
  }

  // Registration Method (For Customers/Sellers)
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    String role = 'customer',
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'role': role,
        },
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}