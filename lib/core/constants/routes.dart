import 'package:flutter/material.dart';

import '../../features/auth/screens/email_verify_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dog_profile/screens/dog_detail_screen.dart';
import '../../features/dog_profile/screens/dog_edit_screen.dart';
import '../../features/dog_profile/screens/dog_list_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ranking/screens/ranking_screen.dart';
import '../../features/walk/screens/walk_active_screen.dart';
import '../../features/walk/screens/walk_detail_screen.dart';
import '../../features/walk/screens/walk_history_screen.dart';
import '../../features/walk/screens/walk_result_screen.dart';
import '../../features/walk/screens/walk_start_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailVerify = '/email-verify';
  static const String forgotPassword = '/forgot-password';
  static const String dogList = '/dogs';
  static const String dogDetail = '/dogs/detail';
  static const String dogEdit = '/dogs/edit';
  static const String walkStart = '/walk/start';
  static const String walkActive = '/walk/active';
  static const String walkHistory = '/walk/history';
  static const String walkDetail = '/walk/detail';
  static const String walkResult = '/walk/result';
  static const String ranking = '/ranking';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    emailVerify: (_) => const EmailVerifyScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    dogList: (_) => const DogListScreen(),
    dogDetail: (_) => const DogDetailScreen(),
    dogEdit: (_) => const DogEditScreen(),
    walkStart: (_) => const WalkStartScreen(),
    walkActive: (_) => const WalkActiveScreen(),
    walkHistory: (_) => const WalkHistoryScreen(),
    walkDetail: (_) => const WalkDetailScreen(),
    walkResult: (_) => const WalkResultScreen(),
    ranking: (_) => const RankingScreen(),
  };

  const AppRoutes._();
}
