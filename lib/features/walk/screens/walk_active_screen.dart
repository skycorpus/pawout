import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../../ranking/providers/ranking_provider.dart';
import '../providers/walk_provider.dart';
import 'walk_result_screen.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '산책 종료',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('산책을 종료할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '계속 산책',
              style: TextStyle(color: AppColors.text2),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final walkProvider = context.read<WalkProvider>();
    final dogProvider = context.read<DogProvider>();

    // stopWalk() 호출 전에 값 저장 (호출 후 초기화됨)
    final dogIds = walkProvider.currentDogIds;
    final dogId = walkProvider.currentDogId;
    final steps = walkProvider.steps;
    final distanceKm = walkProvider.distanceKm;
    final elapsed = walkProvider.elapsed;
    final routePoints = List<Map<String, double>>.from(walkProvider.routePoints);
    final selectedDogs = dogProvider.dogs
        .where((d) => d.id != null && dogIds.contains(d.id))
        .toList();

    final stopResult = await walkProvider.stopWalk();
    if (!context.mounted) return;

    if (stopResult == StopWalkResult.saved && dogId != null) {
      final rankingProvider = context.read<RankingProvider>();
      final streak = walkProvider.currentStreak;
      for (final selectedDogId in dogIds) {
        await rankingProvider.updateDogRanking(
          dogId: selectedDogId,
          steps: steps,
          distanceKm: distanceKm,
        );
      }
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.walkResult,
          arguments: WalkResult(
            steps: steps,
            distanceKm: distanceKm,
            elapsed: elapsed,
            dogName: _buildDogLabel(selectedDogs),
            routePoints: routePoints,
            streak: streak,
          ),
        );
      }
    } else if (stopResult == StopWalkResult.tooShort && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('100m 이상, 1분 이상 산책해야 기록이 저장됩니다.'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (stopResult == StopWalkResult.error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            walkProvider.errorMessage ?? '산책 종료에 실패했습니다.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _buildDogLabel(List<dynamic> dogs) {
    if (dogs.isEmpty) return '';
    if (dogs.length == 1) return dogs.first.name as String;
    return '${dogs.first.name} 외 ${dogs.length - 1}마리';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer2<WalkProvider, DogProvider>(
            builder: (context, walkProvider, dogProvider, _) {
              final walkingDogs = dogProvider.dogs
                  .where((d) => d.id != null &&
                      walkProvider.currentDogIds.contains(d.id))
                  .toList();
              final dogLabel = _buildDogLabel(walkingDogs);

              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ── 상태 표시 ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '산책 중',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    if (dogLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        dogLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ── 타이머 ──
                    Text(
                      _formatDuration(walkProvider.elapsed),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── 통계 3개 ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.directions_walk_rounded,
                              value: walkProvider.steps.toString(),
                              label: '걸음수',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.route_rounded,
                              value: walkProvider.distanceKm
                                  .toStringAsFixed(2),
                              label: 'km',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer_rounded,
                              value: _formatDuration(walkProvider.elapsed),
                              label: '시간',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 실시간 지도 ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _LiveMap(
                          routePoints: walkProvider.routePoints,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 종료 버튼 ──
                    GestureDetector(
                      onTap: () => _confirmStop(context),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop_rounded,
                              color: AppColors.greenDark,
                              size: 36,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '종료',
                              style: TextStyle(
                                color: AppColors.greenDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
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
      ),
    );
  }
}

// ── 실시간 경로 지도 ───────────────────────────────────────────────────

class _LiveMap extends StatefulWidget {
  const _LiveMap({required this.routePoints});
  final List<Map<String, double>> routePoints;

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap> {
  NaverMapController? _controller;

  @override
  void didUpdateWidget(_LiveMap old) {
    super.didUpdateWidget(old);
    if (widget.routePoints.length != old.routePoints.length) {
      _updateMap();
    }
  }

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    _updateMap();
  }

  void _updateMap() {
    final controller = _controller;
    if (controller == null || widget.routePoints.isEmpty) return;

    final latLngs = widget.routePoints
        .map((p) => NLatLng(p['latitude']!, p['longitude']!))
        .toList();

    controller.clearOverlays();

    if (latLngs.length >= 2) {
      controller.addOverlay(NPolylineOverlay(
        id: 'route',
        coords: latLngs,
        color: Colors.white,
        width: 5,
      ));
    }

    controller.addOverlay(
      NMarker(id: 'current', position: latLngs.last)
        ..setIconTintColor(Colors.white),
    );

    controller.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: latLngs.last, zoom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routePoints.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_searching,
                  color: Colors.white54, size: 32),
              SizedBox(height: 8),
              Text(
                'GPS 신호 수신 중...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final last = widget.routePoints.last;
    final initialPos = NLatLng(last['latitude']!, last['longitude']!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: initialPos, zoom: 16),
          scrollGesturesEnable: false,
          zoomGesturesEnable: false,
          tiltGesturesEnable: false,
          rotationGesturesEnable: false,
          logoAlign: NLogoAlign.leftBottom,
        ),
        onMapReady: _onMapReady,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
