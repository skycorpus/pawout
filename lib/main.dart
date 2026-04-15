import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/routes.dart';
import 'core/widgets/paw_svg.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dog_profile/providers/dog_provider.dart';
import 'features/walk/providers/goal_provider.dart';
import 'features/walk/providers/walk_provider.dart';
import 'features/ranking/providers/ranking_provider.dart';
import 'features/likes/providers/likes_provider.dart';
import 'features/follows/providers/follows_provider.dart';
import 'features/alerts/providers/alerts_provider.dart';
import 'features/common_code/providers/common_code_provider.dart';
import 'features/feed/providers/feed_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  await NaverMapSdk.instance.initialize(
    clientId: const String.fromEnvironment('NAVER_MAP_CLIENT_ID'),
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
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => WalkProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
        ChangeNotifierProvider(create: (_) => LikesProvider()),
        ChangeNotifierProvider(create: (_) => FollowsProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
        ChangeNotifierProvider(create: (_) => CommonCodeProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'PawOut',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF4CAF50),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFF8E1),
          fontFamily: 'SF Pro Display',
        ),
        home: const SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

// ── Splash Screen ────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pawScale;
  late Animation<double> _pawRotate;
  late Animation<double> _labelFade;
  late Animation<Offset> _labelSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pawScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.58, curve: Curves.elasticOut),
      ),
    );
    _pawRotate = Tween<double>(begin: -0.31, end: -0.17).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.58, curve: Curves.elasticOut),
      ),
    );
    _labelFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.33, 0.67)),
    );
    _labelSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.33, 0.67, curve: Curves.easeOut),
    ));
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.42, 0.75)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.42, 0.75, curve: Curves.easeOut),
    ));
    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.67, 1.0)),
    );

    _ctrl.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (user.emailConfirmedAt != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.emailVerify,
          arguments: user.email ?? '',
        );
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1), Color(0xFFFFF0C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // bg circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.055),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.045),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.04),
                ),
              ),
            ),

            // main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // paw icon (animated) — 레퍼런스 SVG 그대로 사용
                    AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, __) => Transform.scale(
                        scale: _pawScale.value,
                        child: Transform.rotate(
                          angle: _pawRotate.value,
                          child: const SplashPawSvg(size: 220),
                        ),
                      ),
                    ),

                    // PawOut label
                    FadeTransition(
                      opacity: _labelFade,
                      child: SlideTransition(
                        position: _labelSlide,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'PAWOUT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFBCAAA4),
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // title
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -1,
                                height: 1.15,
                              ),
                              children: [
                                TextSpan(text: "Let's "),
                                TextSpan(
                                  text: 'PawOut',
                                  style: TextStyle(color: Color(0xFF4CAF50)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // catch phrase
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '당신의 강아지와 함께하는\n모든 순간을 기록하세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C6C70),
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 시작하기 button
                    FadeTransition(
                      opacity: _btnFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50)
                                  .withValues(alpha: 0.38),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 건너뛰기
                    FadeTransition(
                      opacity: _btnFade,
                      child: const Text(
                        '건너뛰기',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAEAEB2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

