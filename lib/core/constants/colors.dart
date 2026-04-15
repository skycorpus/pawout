import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── background ──
  static const Color background = Color(0xFFFFF8E1);

  // ── green ──
  static const Color green = Color(0xFF4CAF50);
  static const Color greenDark = Color(0xFF388E3C);
  static const Color greenLight = Color(0xFFE8F5E9);

  // ── brown ──
  static const Color brown = Color(0xFF8D6E63);
  static const Color brownDark = Color(0xFF6D4C41);
  static const Color brownLight = Color(0xFFEFEBE9);
  static const Color brownMid = Color(0xFFBCAAA4);

  // ── text ──
  static const Color text1 = Color(0xFF1C1C1E);
  static const Color text2 = Color(0xFF6C6C70);
  static const Color text3 = Color(0xFFAEAEB2);

  // ── white ──
  static const Color white = Color(0xFFFFFFFF);

  // ── status ──
  static const Color error = Color(0xFFE53935);

  // ── gradients ──
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashBg = LinearGradient(
    colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1), Color(0xFFFFF0C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient pawFabGradient = LinearGradient(
    colors: [Color(0xFFA1887F), Color(0xFF6D4C41)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── legacy aliases (keep existing screens compiling) ──
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF8D6E63);
  static const Color accent = Color(0xFFFFD93D);
  static const Color cardBackground = white;
  static const Color textPrimary = text1;
  static const Color textSecondary = text2;
  static const Color textHint = text3;
  static const Color success = green;
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);
  static const LinearGradient primaryGradient = heroGradient;
}
