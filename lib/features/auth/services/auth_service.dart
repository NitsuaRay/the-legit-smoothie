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

      return profile['role'] as String;
    } catch (e) {
      throw e.toString();
    }
  }

  // Registration Method (Customers Only)
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    required String region,
    required String province,
    required String cityMunicipality,
    required String barangay,
    required String streetAddress,
    required bool termsAccepted,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // 1. Sign up user as 'customer'
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': '$firstName $lastName',
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'role': 'customer',
          'terms_accepted': termsAccepted,
          'terms_accepted_at': now,
        },
      );

      final user = response.user;
      if (user == null) {
        throw 'Registration failed. User creation returned null.';
      }

      // 2. Insert primary address into public.addresses
      await _supabase.from('addresses').insert({
        'user_id': user.id,
        'region': region,
        'province': province,
        'city_municipality': cityMunicipality,
        'barangay': barangay,
        'street_address': streetAddress,
        'is_default': true,
      });

      // 3. Update public.profiles table with terms tracking
      await _supabase.from('profiles').update({
        'terms_accepted': termsAccepted,
        'terms_accepted_at': now,
      }).eq('id', user.id);

    } catch (e) {
      throw e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}