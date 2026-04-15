import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailConfirmedAt != null;
  String get currentUserId => _currentUser?.id ?? '';
  String get currentUserName =>
      _currentUser?.userMetadata?['name'] as String? ?? 'User';
  String get currentUserEmail => _currentUser?.email ?? '';

  AuthProvider() {
    // 현재 세션 확인
    _currentUser = _supabase.auth.currentUser;

    // 인증 상태 변화 리스닝
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

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
      // 1. Supabase Auth에 회원가입
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // 메타데이터
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다');
      }

      // 2. profiles 테이블에 사용자 정보 저장
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
      });

      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getKoreanErrorMessage(e.message);
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
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('로그인에 실패했습니다');
      }

      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getKoreanErrorMessage(e.message);
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
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // 프로필 이름 수정
  Future<bool> updateProfile({required String name}) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Auth 메타데이터 업데이트
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {'name': name}),
      );
      // profiles 테이블도 업데이트
      await _supabase
          .from('profiles')
          .update({'name': name})
          .eq('id', _currentUser!.id);

      _currentUser = response.user ?? _currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 이메일 인증 재발송
  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getKoreanErrorMessage(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 비밀번호 재설정 이메일 전송
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 에러 메시지 한글화
  String _getKoreanErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다';
    } else if (message.contains('Email not confirmed')) {
      return '이메일 인증이 필요합니다';
    } else if (message.contains('User already registered')) {
      return '이미 가입된 이메일입니다';
    } else if (message.contains('Password should be at least 6 characters')) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return message;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
