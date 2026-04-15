import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../dog_profile/models/dog_model.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../providers/walk_provider.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});

  @override
  State<WalkHistoryScreen> createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dogProvider = context.read<DogProvider>();
      if (dogProvider.dogs.isEmpty) {
        await dogProvider.fetchDogs();
      }
      if (!mounted) {
        return;
      }
      final dogIds = dogProvider.dogs
          .where((dog) => dog.id != null)
          .map((dog) => dog.id!)
          .toList();
      context.read<WalkProvider>().fetchWalks(dogIds);
    });
  }

  String _formatDate(DateTime value) {
    return '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _dogLabel(List<Dog> dogs) {
    if (dogs.isEmpty) {
      return '강아지';
    }
    if (dogs.length == 1) {
      return dogs.first.name;
    }
    return '${dogs.first.name} 외 ${dogs.length - 1}마리';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '산책 기록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.text1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<WalkProvider, DogProvider>(
        builder: (context, walkProvider, dogProvider, _) {
          if (walkProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }

          if (walkProvider.walks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_walk, size: 80, color: AppColors.green),
                  SizedBox(height: 16),
                  Text(
                    '아직 산책 기록이 없습니다.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '강아지와 첫 산책을 시작해보세요.',
                    style: TextStyle(color: AppColors.text2),
                  ),
                ],
              ),
            );
          }

          final dogMap = {for (final dog in dogProvider.dogs) dog.id: dog};

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: walkProvider.walks.length,
            itemBuilder: (context, index) {
              final walk = walkProvider.walks[index];
              final walkDogs = walk.dogIds
                  .map((dogId) => dogMap[dogId])
                  .whereType<Dog>()
                  .toList();

              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/walk/detail',
                  arguments: walk,
                ),
                child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pets, color: AppColors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _dogLabel(walkDogs),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.text1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(walk.startTime),
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _HistoryStat(
                          icon: Icons.timer,
                          value: '${walk.durationMinutes}분',
                          label: '시간',
                        ),
                        _HistoryStat(
                          icon: Icons.route,
                          value: '${walk.distanceKm.toStringAsFixed(2)}km',
                          label: '거리',
                        ),
                        _HistoryStat(
                          icon: Icons.directions_walk,
                          value: '${walk.steps}',
                          label: '걸음',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.green, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.text1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
