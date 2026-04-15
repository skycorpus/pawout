import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/widgets/dog_card.dart';
import '../../../core/widgets/paw_bottom_nav.dart';
import '../../../core/widgets/paw_svg.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/walk_hero_card.dart';
import '../../alerts/models/alert_model.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common_code/providers/common_code_provider.dart';
import '../../dog_profile/models/dog_model.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../follows/providers/follows_provider.dart';
import '../../ranking/providers/ranking_provider.dart';
import '../../ranking/screens/ranking_screen.dart';
import '../../walk/providers/goal_provider.dart';
import '../../walk/providers/walk_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _handleNavTap(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.walkStart);
      return;
    }
    setState(() => _currentIndex = index);
    if (index == 1) {
      _loadAlerts();
    }
    if (index == 3) {
      context.read<RankingProvider>().fetchRankings(RankingPeriod.daily);
    }
  }

  void _loadAlerts() {
    final dogProvider = context.read<DogProvider>();
    final authProvider = context.read<AuthProvider>();
    final myDogIds = dogProvider.dogs
        .where((d) => d.id != null)
        .map((d) => d.id!)
        .toList();
    final myUserId = authProvider.currentUserId;
    if (myUserId.isNotEmpty) {
      context.read<AlertsProvider>().fetchAlerts(
            myDogIds: myDogIds,
            myUserId: myUserId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),        // 0
          _AlertsTab(),      // 1
          SizedBox.shrink(), // 2 – FAB, never shown
          RankingScreen(),   // 3
          _ProfileTab(),     // 4
        ],
      ),
      bottomNavigationBar: Consumer<AlertsProvider>(
        builder: (_, alertsProvider, __) => PawBottomNav(
          currentIndex: _currentIndex,
          onTap: _handleNavTap,
          alertCount: alertsProvider.unreadCount,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// HOME TAB
// ════════════════════════════════════════════════════════════════════

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dogProvider = context.read<DogProvider>();
      final commonCodeProvider = context.read<CommonCodeProvider>();
      final walkProvider = context.read<WalkProvider>();
      final authProvider = context.read<AuthProvider>();
      final feedProvider = context.read<FeedProvider>();

      await dogProvider.fetchDogs();
      if (!mounted) return;

      commonCodeProvider.fetchGroup('BREED');

      final dogIds = dogProvider.dogs
          .where((d) => d.id != null)
          .map((d) => d.id!)
          .toList();
      if (dogIds.isNotEmpty) {
        walkProvider.fetchWalks(dogIds);
      }

      final myUserId = authProvider.currentUserId;
      feedProvider.fetchFeed(myUserId: myUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUserName;
    final initial =
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer3<DogProvider, WalkProvider, GoalProvider>(
          builder: (context, dogProvider, walkProvider, goalProvider, _) {
            final dogs = dogProvider.dogs;
            final firstDog = dogs.isNotEmpty ? dogs.first : null;
            final todaySteps = walkProvider.todayTotalSteps;

            return CustomScrollView(
              slivers: [
                // ── nav header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.text2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                const Text(
                                  'PawOut',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const NavPawSvg(width: 22, height: 20),
                              ],
                            ),
                          ],
                        ),
                        // avatar
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brown,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── hero card ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WalkHeroCard(
                      dogName: firstDog?.name ?? 'your dog',
                      todaySteps: todaySteps,
                      streak: walkProvider.currentStreak,
                      onStartWalk: () =>
                          Navigator.pushNamed(context, AppRoutes.walkStart),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 11)),

                // ── progress card ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProgressCard(
                        todaySteps, goalProvider.goalSteps, context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 13)),

                // ── section: My dogs ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(
                      icon: const NavPawSvg(width: 15, height: 14, opacity: 0.85),
                      title: 'My dogs',
                      trailing: dogs.isNotEmpty
                          ? GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRoutes.dogList),
                              child: const Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 9)),

                // ── dog cards horizontal scroll ──
                SliverToBoxAdapter(
                  child: dogProvider.isLoading
                      ? const DogCardSkeleton()
                      : dogs.isEmpty
                          ? _EmptyDogsPrompt(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.dogList,
                              ),
                            )
                          : _DogCardsList(dogs: dogs),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 13)),

                // ── section: Recent activity ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(
                      icon: const _ClockIcon(),
                      title: 'Recent activity',
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 9)),

                // ── activity cards ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _RecentActivitySection(
                      walkProvider: walkProvider,
                      dogs: dogs,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 13)),

                // ── section: Community feed ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(
                      icon: const Icon(
                        Icons.people_outline,
                        size: 15,
                        color: AppColors.text2,
                      ),
                      title: 'Community',
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 9)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Consumer<FeedProvider>(
                      builder: (context, feedProvider, _) =>
                          _CommunityFeedSection(feedProvider: feedProvider),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCard(int steps, int goal, BuildContext context) {
    final fraction = (steps / goal).clamp(0.0, 1.0);
    final remaining = (goal - steps).clamp(0, goal);

    return GestureDetector(
      onTap: () => _showGoalDialog(context, goal),
      child: ProgressGoalCard(
        progressFraction: fraction,
        subtitle:
            '${_formatSteps(steps)} 걸음 완료 · ${_formatSteps(remaining)} 걸음 남음',
      ),
    );
  }

  Future<void> _showGoalDialog(BuildContext context, int currentGoal) async {
    final controller =
        TextEditingController(text: currentGoal.toString());
    final newGoal = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '하루 목표 걸음수',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '예: 8000',
            suffixText: '걸음',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.green),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: AppColors.text2)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (newGoal != null && context.mounted) {
      context.read<GoalProvider>().setGoalSteps(newGoal);
    }
  }

  String _formatSteps(int s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}k';
    return s.toString();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Dog cards horizontal list ──────────────────────────────────────

class _DogCardsList extends StatelessWidget {
  const _DogCardsList({required this.dogs});
  final List<Dog> dogs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 10),
        itemCount: dogs.length,
        itemBuilder: (context, i) {
          final dog = dogs[i];
          final gradIndex = i % kDogCardGradients.length;
          final bgIndex = i % kDogAvatarBgColors.length;
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: DogCard(
              name: dog.name,
              breed: dog.breed,
              age: dog.age,
              isActive: i % 2 == 0, // replace with real walk status if available
              headerGradient: kDogCardGradients[gradIndex],
              avatarBgColor: kDogAvatarBgColors[bgIndex],
              profileImageUrl: dog.profileImageUrl,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.dogDetail,
                arguments: dog,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Empty dogs prompt ──────────────────────────────────────────────

class _EmptyDogsPrompt extends StatelessWidget {
  const _EmptyDogsPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.green, width: 1.5),
          ),
          child: const Column(
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: AppColors.green),
              SizedBox(height: 8),
              Text(
                '강아지를 등록해보세요!',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent activity section ────────────────────────────────────────

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.walkProvider,
    required this.dogs,
  });

  final WalkProvider walkProvider;
  final List<Dog> dogs;

  @override
  Widget build(BuildContext context) {
    final walks = walkProvider.walks;

    if (walks.isEmpty) {
      return ActivityCard(
        iconBgColor: AppColors.greenLight,
        icon: Icons.directions_walk,
        title: '산책을 시작해보세요',
        subtitle: '첫 산책 기록이 여기에 표시됩니다',
        timeLabel: '',
        onTap: () => Navigator.pushNamed(context, AppRoutes.walkStart),
      );
    }

    return Column(
      children: walks.take(3).map((walk) {
        final walkDogs = dogs
            .where((d) => d.id != null && walk.dogIds.contains(d.id))
            .toList();
        final mins = walk.endTime != null
            ? walk.endTime!.difference(walk.startTime).inMinutes
            : 0;
        final distStr =
            '${walk.distanceKm.toStringAsFixed(1)} km · $mins min';
        final dogName = walkDogs.isEmpty
            ? ''
            : walkDogs.length == 1
                ? walkDogs.first.name
                : '${walkDogs.first.name} 외 ${walkDogs.length - 1}마리';
        final sub = dogName.isNotEmpty ? '$dogName · $distStr' : distStr;
        final hour = walk.startTime.hour;
        final ampm = hour < 12 ? 'AM' : 'PM';
        final h = hour % 12 == 0 ? 12 : hour % 12;

        return ActivityCard(
          iconBgColor: AppColors.greenLight,
          icon: Icons.directions_walk,
          title: '산책 기록',
          subtitle: sub,
          timeLabel: '$h $ampm',
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.walkHistory),
        );
      }).toList(),
    );
  }
}

// ── Community feed section ─────────────────────────────────────────

class _CommunityFeedSection extends StatelessWidget {
  const _CommunityFeedSection({required this.feedProvider});
  final FeedProvider feedProvider;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    if (feedProvider.isLoading) {
      return const FeedListSkeleton();
    }

    if (feedProvider.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '아직 커뮤니티 활동이 없습니다',
            style: TextStyle(color: AppColors.text2, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: feedProvider.items.take(5).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // dog avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.brownLight,
                  image: item.dogImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.dogImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.dogImageUrl == null
                    ? const Icon(Icons.pets,
                        color: AppColors.brown, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text1,
                        ),
                        children: [
                          TextSpan(
                            text: item.ownerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: '님의 '),
                          TextSpan(
                            text: item.dogName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.green),
                          ),
                          const TextSpan(text: ' 산책'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.distanceKm.toStringAsFixed(1)} km · '
                      '${item.steps} 걸음 · '
                      '${item.elapsed.inMinutes}분',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(item.endTime),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final Widget icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text1,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Clock icon widget ──────────────────────────────────────────────

class _ClockIcon extends StatelessWidget {
  const _ClockIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 14,
      child: CustomPaint(painter: _ClockIconPainter()),
    );
  }
}

class _ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.text2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r, paint);
    canvas.drawLine(c, Offset(c.dx, c.dy - r * 0.55), paint);
    canvas.drawLine(c, Offset(c.dx + r * 0.38, c.dy + r * 0.25), paint);
  }

  @override
  bool shouldRepaint(_ClockIconPainter old) => false;
}

// ════════════════════════════════════════════════════════════════════
// ALERTS TAB
// ════════════════════════════════════════════════════════════════════

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AlertsProvider>(
        builder: (context, alertsProvider, _) {
          if (alertsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }

          if (alertsProvider.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: AppColors.text3),
                  const SizedBox(height: 12),
                  const Text(
                    '아직 알림이 없습니다',
                    style: TextStyle(color: AppColors.text2, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '산책 후 랭킹에 오르면 좋아요 알림이 와요!',
                    style:
                        TextStyle(color: AppColors.text3, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.green,
            onRefresh: () async {
              final dogProvider = context.read<DogProvider>();
              final authProvider = context.read<AuthProvider>();
              final myDogIds = dogProvider.dogs
                  .where((d) => d.id != null)
                  .map((d) => d.id!)
                  .toList();
              await alertsProvider.fetchAlerts(
                myDogIds: myDogIds,
                myUserId: authProvider.currentUserId,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: alertsProvider.alerts.length,
              itemBuilder: (context, index) {
                final alert = alertsProvider.alerts[index];
                final isLike = alert.type == AlertType.like;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isLike
                              ? AppColors.error.withValues(alpha: 0.10)
                              : AppColors.greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLike
                              ? Icons.favorite_rounded
                              : Icons.person_add_rounded,
                          color: isLike ? AppColors.error : AppColors.green,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          alert.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.text1,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(alert.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════
// PROFILE TAB
// ════════════════════════════════════════════════════════════════════

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
      context.read<DogProvider>().fetchDogs();
      context.read<CommonCodeProvider>().fetchGroup('BREED');
    });
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.currentUserName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '이름 변경',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '새 이름 입력',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.green),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppColors.text2)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.pop(ctx, v);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (newName != null && mounted) {
      final success = await auth.updateProfile(name: newName);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? '이름 변경에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUserName;
    final userEmail = auth.currentUserEmail;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.text2),
            onPressed: () => _showEditNameDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // user card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brown,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // follow counts
            Consumer<FollowsProvider>(
              builder: (_, fp, __) => Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CountCell(label: '팔로워', count: fp.followersCount),
                    Container(width: 1, height: 40, color: Colors.grey.shade200),
                    _CountCell(label: '팔로잉', count: fp.followingCount),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '내 강아지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text1,
              ),
            ),
            const SizedBox(height: 12),
            Consumer2<DogProvider, CommonCodeProvider>(
              builder: (_, dogProvider, codeProvider, __) {
                if (dogProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.green,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (dogProvider.dogs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        '등록된 강아지가 없습니다.',
                        style: TextStyle(color: AppColors.text2),
                      ),
                    ),
                  );
                }
                return Column(
                  children: dogProvider.dogs.map((dog) {
                    final breedName = codeProvider.getCodeName('BREED', dog.breed);
                    final genderLabel = dog.gender == 'male' ? '수컷' : '암컷';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppColors.brownLight,
                              image: dog.profileImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(dog.profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: dog.profileImageUrl == null
                                ? const Icon(Icons.pets, color: AppColors.brown, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      dog.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.text1,
                                      ),
                                    ),
                                    if (dog.isNeutered) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.teal.shade200),
                                        ),
                                        child: Text(
                                          '중성화',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.teal.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$breedName · ${dog.age}살 · $genderLabel · ${dog.weight}kg',
                                  style: const TextStyle(
                                    color: AppColors.text2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountCell extends StatelessWidget {
  const _CountCell({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.text3, fontSize: 13),
        ),
      ],
    );
  }
}
