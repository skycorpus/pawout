import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../../walk/screens/walk_start_screen.dart';
import '../../ranking/screens/ranking_screen.dart';
import '../../../core/constants/routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../follows/providers/follows_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    WalkStartScreen(),
    RankingScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B9D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_walk), label: '산책'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '랭킹'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}

// 홈 탭
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DogProvider>().fetchDogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'PawOut 🐾',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFF6B9D)),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.dogList),
            tooltip: '강아지 관리',
          ),
        ],
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, _) {
          if (dogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인사말
                const Text(
                  '안녕하세요! 👋',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '오늘도 강아지와 즐거운 산책 하세요',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),

                // 산책 시작 배너
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.walkStart),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '산책 시작하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '강아지와 함께 건강한 하루를!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.directions_walk,
                            color: Colors.white, size: 48),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 내 강아지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '내 강아지',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.dogList),
                      child: const Text('전체보기',
                          style: TextStyle(color: Color(0xFFFF6B9D))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (dogProvider.dogs.isEmpty)
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.dogList),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFFF6B9D), width: 1.5,
                            style: BorderStyle.solid),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 40, color: Color(0xFFFF6B9D)),
                          SizedBox(height: 8),
                          Text('강아지를 등록해보세요!',
                              style: TextStyle(
                                  color: Color(0xFFFF6B9D),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dogProvider.dogs.length,
                      itemBuilder: (context, index) {
                        final dog = dogProvider.dogs[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFFF6B9D)
                                    .withValues(alpha: 0.1),
                                backgroundImage: dog.profileImageUrl != null
                                    ? NetworkImage(dog.profileImageUrl!)
                                    : null,
                                child: dog.profileImageUrl == null
                                    ? const Icon(Icons.pets,
                                        color: Color(0xFFFF6B9D), size: 26)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dog.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${dog.age}살',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 28),

                // 산책 기록 바로가기
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.walkHistory),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.history, color: Color(0xFFFF6B9D), size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('산책 기록',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text('지난 산책 기록을 확인해보세요',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 프로필 탭
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowsProvider>().fetchMyCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('프로필',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FollowsProvider>(
        builder: (context, followsProvider, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFFF6B9D),
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // 팔로워 / 팔로잉 수
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CountCard(
                      label: '팔로워',
                      count: followsProvider.followersCount,
                    ),
                    const SizedBox(width: 32),
                    _CountCard(
                      label: '팔로잉',
                      count: followsProvider.followingCount,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('로그아웃'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
