import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/routes.dart';
import '../providers/walk_provider.dart';
import '../../ranking/providers/ranking_provider.dart';

class WalkActiveScreen extends StatelessWidget {
  const WalkActiveScreen({super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _confirmStop(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('산책 종료'),
        content: const Text('산책을 종료할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 산책'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final walkProvider = context.read<WalkProvider>();
      final dogId = walkProvider.currentDogId;
      final steps = walkProvider.steps;
      final distanceKm = walkProvider.distanceKm;

      final success = await walkProvider.stopWalk();
      if (context.mounted) {
        if (success && dogId != null) {
          // 랭킹 업데이트
          await context.read<RankingProvider>().updateDogRanking(
                dogId: dogId,
                steps: steps,
                distanceKm: distanceKm,
              );
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.walkHistory);
          }
        } else if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<WalkProvider>().errorMessage ?? '저장에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFF6B9D),
        body: Consumer<WalkProvider>(
          builder: (context, walkProvider, _) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    '산책 중 🐾',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 8),

                  // 경과 시간
                  Text(
                    _formatDuration(walkProvider.elapsed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 걸음수 / 거리
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(
                          icon: Icons.directions_walk,
                          value: walkProvider.steps.toString(),
                          label: '걸음수',
                        ),
                        _StatCard(
                          icon: Icons.route,
                          value: walkProvider.distanceKm.toStringAsFixed(2),
                          label: 'km',
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 종료 버튼
                  GestureDetector(
                    onTap: () => _confirmStop(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_rounded,
                              color: Color(0xFFFF6B9D), size: 40),
                          Text(
                            '종료',
                            style: TextStyle(
                                color: Color(0xFFFF6B9D),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
