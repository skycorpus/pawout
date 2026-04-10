import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 로그인
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 API 호출로 교체
      // final response = await apiService.login(email, password);

      // 임시 로직 (2초 대기)
      await Future.delayed(const Duration(seconds: 2));

      // 임시 유효성 검사
      if (email.isEmpty || password.isEmpty) {
        throw Exception('이메일과 비밀번호를 입력해주세요');
      }

      if (password.length < 6) {
        throw Exception('비밀번호는 6자 이상이어야 합니다');
      }

      // 임시 토큰 저장
      _token = 'temp_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      // SharedPreferences에 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // 회원가입
  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(seconds: 2));

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('모든 필드를 입력해주세요');
      }

      if (!email.contains('@')) {
        throw Exception('올바른 이메일 형식이 아닙니다');
      }

      // 회원가입 성공 후 자동 로그인
      _token = 'temp_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }

  // 자동 로그인 체크 (앱 시작 시)
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('auth_token')) {
      return;
    }

    _token = prefs.getString('auth_token');
    _isAuthenticated = true;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
