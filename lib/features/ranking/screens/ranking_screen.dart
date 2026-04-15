import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../../follows/providers/follows_provider.dart';
import '../../likes/providers/likes_provider.dart';
import '../models/ranking_model.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingPeriod _period = RankingPeriod.daily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(_period);
    });
  }

  Future<void> _load(RankingPeriod period) async {
    final rankingProvider = context.read<RankingProvider>();
    await rankingProvider.fetchRankings(period);
    if (!mounted) return;
    final dogIds = rankingProvider.rankings.map((e) => e.dogId).toList();
    context.read<LikesProvider>().fetchMyLikes();
    context.read<LikesProvider>().fetchLikeCounts(dogIds);
    context.read<FollowsProvider>().fetchMyFollows();
  }

  void _onPeriodChanged(RankingPeriod period) {
    if (_period == period) return;
    setState(() => _period = period);
    _load(period);
  }

  String _periodLabel(RankingPeriod p) {
    switch (p) {
      case RankingPeriod.daily:
        return '일간';
      case RankingPeriod.weekly:
        return '주간';
      case RankingPeriod.monthly:
        return '월간';
    }
  }

  String _dateLabel() {
    final now = DateTime.now();
    switch (_period) {
      case RankingPeriod.daily:
        return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
      case RankingPeriod.weekly:
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        return '${monday.month}/${monday.day} – ${now.month}/${now.day}';
      case RankingPeriod.monthly:
        return '${now.year}년 ${now.month}월';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '랭킹',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _dateLabel(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 내 순위 칩
                  Consumer2<RankingProvider, DogProvider>(
                    builder: (_, rankingProvider, dogProvider, __) {
                      final myDogIds = dogProvider.dogs
                          .map((d) => d.id)
                          .whereType<int>()
                          .toSet();
                      final rank = rankingProvider.myBestRank(myDogIds);
                      if (rank == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '내 순위 #$rank',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 기간 탭 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.brownLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: RankingPeriod.values.map((p) {
                    final selected = _period == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onPeriodChanged(p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              _periodLabel(p),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.text2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── 본문 ──
            Expanded(
              child: Consumer2<RankingProvider, DogProvider>(
                builder: (context, rankingProvider, dogProvider, _) {
                  if (rankingProvider.isLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green),
                    );
                  }

                  if (rankingProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            rankingProvider.errorMessage!,
                            style:
                                const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _load(_period),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (rankingProvider.rankings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events,
                              size: 72, color: AppColors.brownMid),
                          const SizedBox(height: 16),
                          const Text(
                            '랭킹 데이터가 없습니다',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '산책을 시작하면 랭킹에 등록돼요!',
                            style: TextStyle(color: AppColors.text2),
                          ),
                        ],
                      ),
                    );
                  }

                  final myDogIds = dogProvider.dogs
                      .map((d) => d.id)
                      .whereType<int>()
                      .toSet();

                  return RefreshIndicator(
                    color: AppColors.green,
                    onRefresh: () => _load(_period),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: rankingProvider.rankings.length,
                      itemBuilder: (context, index) {
                        final entry = rankingProvider.rankings[index];
                        final isMyDog = myDogIds.contains(entry.dogId);
                        return _RankingCard(
                          entry: entry,
                          rank: index + 1,
                          isMyDog: isMyDog,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 랭킹 카드 ──────────────────────────────────────────────────────────

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.entry,
    required this.rank,
    required this.isMyDog,
  });

  final RankingEntry entry;
  final int rank;
  final bool isMyDog;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade400;
    }
  }

  Widget get _rankWidget {
    if (rank <= 3) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: _rankColor, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 36,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMyDog ? AppColors.greenLight : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyDog ? AppColors.green : Colors.transparent,
          width: isMyDog ? 1.5 : 0,
        ),
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
          _rankWidget,
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.brownLight,
            backgroundImage: entry.dogImageUrl != null
                ? NetworkImage(entry.dogImageUrl!)
                : null,
            child: entry.dogImageUrl == null
                ? const Icon(Icons.pets, color: AppColors.brown, size: 22)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.dogName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.text1,
                      ),
                    ),
                    if (isMyDog) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '내 강아지',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text(
                      entry.ownerName,
                      style: const TextStyle(
                          color: AppColors.text2, fontSize: 12),
                    ),
                    if (!isMyDog && entry.ownerId != null) ...[
                      const SizedBox(width: 6),
                      Consumer<FollowsProvider>(
                        builder: (context, followsProvider, _) {
                          final following =
                              followsProvider.isFollowing(entry.ownerId!);
                          return GestureDetector(
                            onTap: () => followsProvider
                                .toggleFollow(entry.ownerId!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: following
                                    ? AppColors.brownLight
                                    : AppColors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                following ? '팔로잉' : '팔로우',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: following
                                      ? AppColors.text2
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalSteps}걸음',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.text1),
              ),
              Text(
                '${entry.totalDistanceKm.toStringAsFixed(2)}km',
                style: const TextStyle(
                    color: AppColors.text2, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Consumer<LikesProvider>(
                builder: (context, likesProvider, _) {
                  final liked = likesProvider.isLiked(entry.dogId);
                  final count = likesProvider.getLikeCount(entry.dogId);
                  return GestureDetector(
                    onTap: isMyDog
                        ? null
                        : () => likesProvider.toggleLike(entry.dogId),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: isMyDog
                              ? AppColors.text3
                              : (liked ? AppColors.error : AppColors.text3),
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                liked ? AppColors.error : AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
