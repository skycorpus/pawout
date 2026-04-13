import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RankingProvider>().fetchDailyRankings();
      if (mounted) {
        final dogIds = context
            .read<RankingProvider>()
            .rankings
            .map((e) => e.dogId)
            .toList();
        context.read<LikesProvider>().fetchMyLikes();
        context.read<LikesProvider>().fetchLikeCounts(dogIds);
        context.read<FollowsProvider>().fetchMyFollows();
      }
    });
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 랭킹',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _today(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<RankingProvider, DogProvider>(
        builder: (context, rankingProvider, dogProvider, _) {
          if (rankingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
            );
          }

          if (rankingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    rankingProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rankingProvider.fetchDailyRankings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (rankingProvider.rankings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 80, color: Color(0xFFFF6B9D)),
                  SizedBox(height: 16),
                  Text(
                    '아직 오늘의 랭킹이 없습니다.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '산책을 시작하면 랭킹에 등록돼요!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final myDogIds = dogProvider.dogs.map((d) => d.id).toSet();

          return RefreshIndicator(
            color: const Color(0xFFFF6B9D),
            onRefresh: () async {
              await rankingProvider.fetchDailyRankings();
              final dogIds = rankingProvider.rankings.map((e) => e.dogId).toList();
              context.read<LikesProvider>().fetchMyLikes();
              context.read<LikesProvider>().fetchLikeCounts(dogIds);
              context.read<FollowsProvider>().fetchMyFollows();
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    );
  }
}

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
        color: isMyDog
            ? const Color(0xFFFF6B9D).withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyDog ? const Color(0xFFFF6B9D) : Colors.transparent,
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
            backgroundColor: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
            backgroundImage: entry.dogImageUrl != null
                ? NetworkImage(entry.dogImageUrl!)
                : null,
            child: entry.dogImageUrl == null
                ? const Icon(Icons.pets, color: Color(0xFFFF6B9D), size: 22)
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
                      ),
                    ),
                    if (isMyDog) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (!isMyDog && entry.ownerId != null) ...[
                      const SizedBox(width: 6),
                      Consumer<FollowsProvider>(
                        builder: (context, followsProvider, _) {
                          final following =
                              followsProvider.isFollowing(entry.ownerId!);
                          return GestureDetector(
                            onTap: () =>
                                followsProvider.toggleFollow(entry.ownerId!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: following
                                    ? Colors.grey.shade200
                                    : const Color(0xFFFF6B9D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                following ? '팔로잉' : '팔로우',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: following
                                      ? Colors.grey[600]
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${entry.totalDistanceKm.toStringAsFixed(2)}km',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Consumer<LikesProvider>(
                builder: (context, likesProvider, _) {
                  final liked = likesProvider.isLiked(entry.dogId);
                  final count = likesProvider.getLikeCount(entry.dogId);
                  return GestureDetector(
                    onTap: isMyDog ? null : () => likesProvider.toggleLike(entry.dogId),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: isMyDog
                              ? Colors.grey.shade300
                              : (liked ? const Color(0xFFFF6B9D) : Colors.grey),
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            color: liked ? const Color(0xFFFF6B9D) : Colors.grey,
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
