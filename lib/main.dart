import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/routes.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dog_profile/providers/dog_provider.dart';
import 'features/walk/providers/walk_provider.dart';
import 'features/ranking/providers/ranking_provider.dart';
import 'features/likes/providers/likes_provider.dart';
import 'features/follows/providers/follows_provider.dart';
import 'features/common_code/providers/common_code_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cvxlfjuuzyyzmduynwsp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2eGxmanV1enl5em1kdXlud3NwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMzk5NjksImV4cCI6MjA5MTYxNTk2OX0.0ERV3_Z26JGvNwC9FtXI5aFSl55vHthOwyzcl-yeDjs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DogProvider()),
        ChangeNotifierProvider(create: (_) => WalkProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
        ChangeNotifierProvider(create: (_) => LikesProvider()),
        ChangeNotifierProvider(create: (_) => FollowsProvider()),
        ChangeNotifierProvider(create: (_) => CommonCodeProvider()),
      ],
      child: MaterialApp(
        title: 'PawOut',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFFF6B9D),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B9D),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        ),
        home: const SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

// 스플래시 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B9D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets,
                  size: 80,
                  color: Color(0xFFFF6B9D),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'PawOut',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '우리 강아지와 함께하는 산책',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
