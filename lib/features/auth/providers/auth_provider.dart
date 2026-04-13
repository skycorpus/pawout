import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

  // 회원가입
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      _isLoading = false;
      notifyListeners();
      return response.user != null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
