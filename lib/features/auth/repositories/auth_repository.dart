import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  bool get isAuthenticated => _supabase.auth.currentUser != null;
  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return _supabase.auth.signOut();
  }
}
