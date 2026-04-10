import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dog_profile/screens/dog_detail_screen.dart';
import '../../features/dog_profile/screens/dog_list_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ranking/screens/ranking_screen.dart';
import '../../features/walk/screens/walk_active_screen.dart';
import '../../features/walk/screens/walk_history_screen.dart';
import '../../features/walk/screens/walk_start_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dogList = '/dogs';
  static const String dogDetail = '/dogs/detail';
  static const String walkStart = '/walk/start';
  static const String walkActive = '/walk/active';
  static const String walkHistory = '/walk/history';
  static const String ranking = '/ranking';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    dogList: (_) => const DogListScreen(),
    dogDetail: (_) => const DogDetailScreen(),
    walkStart: (_) => const WalkStartScreen(),
    walkActive: (_) => const WalkActiveScreen(),
    walkHistory: (_) => const WalkHistoryScreen(),
    ranking: (_) => const RankingScreen(),
  };

  const AppRoutes._();
}
