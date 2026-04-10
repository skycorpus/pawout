import 'package:flutter/material.dart';

class AppColors {
  // 브랜드 메인 컬러 (강아지 테마)
  static const Color primary = Color(0xFFFF6B9D); // 핑크
  static const Color secondary = Color(0xFFFFA07A); // 코랄
  static const Color accent = Color(0xFFFFD93D); // 옐로우

  // 배경색
  static const Color background = Color(0xFFFFF8F0);
  static const Color cardBackground = Colors.white;

  // 텍스트
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // 상태 색상
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF7675);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
