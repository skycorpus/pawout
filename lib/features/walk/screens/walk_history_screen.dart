import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';
import '../../dog_profile/providers/dog_provider.dart';

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
      if (mounted) {
        final dogIds = dogProvider.dogs
            .where((d) => d.id != null)
            .map((d) => d.id!)
            .toList();
        context.read<WalkProvider>().fetchWalks(dogIds);
      }
    });
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('산책 기록', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<WalkProvider, DogProvider>(
        builder: (context, walkProvider, dogProvider, _) {
          if (walkProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
            );
          }

          if (walkProvider.walks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_walk,
                      size: 80, color: Color(0xFFFF6B9D)),
                  SizedBox(height: 16),
                  Text(
                    '아직 산책 기록이 없어요',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('강아지와 첫 산책을 시작해보세요!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final dogMap = {for (final d in dogProvider.dogs) d.id: d};

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: walkProvider.walks.length,
            itemBuilder: (context, index) {
              final walk = walkProvider.walks[index];
              final dog = dogMap[walk.dogId];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                        const Icon(Icons.pets,
                            color: Color(0xFFFF6B9D), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          dog?.name ?? '강아지',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(walk.startTime),
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
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
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6B9D), size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
