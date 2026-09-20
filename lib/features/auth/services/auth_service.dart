import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser =>
      _supabase.auth.currentUser;

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<AuthResponse> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {
        'full_name': fullName.trim(),
      },
    );
  }

  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  Future<Map<String, dynamic>?>
      getCurrentUserProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  // ============================================================
  // GET CURRENT USER ROLE
  // ============================================================

  Future<String?> getCurrentUserRole() async {
    final profile =
        await getCurrentUserProfile();

    if (profile == null) {
      return null;
    }

    final role =
        profile['role']?.toString();

    if (role == null ||
        role.trim().isEmpty) {
      return null;
    }

    return role.trim().toLowerCase();
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}