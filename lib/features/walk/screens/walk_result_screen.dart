import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';

/// 산책 종료 후 결과 summary 화면.
/// arguments: WalkResult (named route arguments)
class WalkResultScreen extends StatelessWidget {
  const WalkResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as WalkResult?;

    final steps = result?.steps ?? 0;
    final distanceKm = result?.distanceKm ?? 0.0;
    final elapsed = result?.elapsed ?? Duration.zero;
    final dogName = result?.dogName ?? '';
    final streak = result?.streak ?? 0;

    final latLngs = result?.routePoints
            .map((p) => NLatLng(p['latitude']!, p['longitude']!))
            .toList() ??
        [];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 완료 헤더 ──
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  dogName.isNotEmpty ? '$dogName와 산책 완료!' : '산책 완료!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _encouragement(steps),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text2,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── 통계 카드 ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ResultStat(
                        icon: Icons.directions_walk_rounded,
                        value: _formatSteps(steps),
                        label: '걸음수',
                        color: AppColors.green,
                      ),
                      _Divider(),
                      _ResultStat(
                        icon: Icons.route_rounded,
                        value: distanceKm.toStringAsFixed(2),
                        label: 'km',
                        color: AppColors.brown,
                      ),
                      _Divider(),
                      _ResultStat(
                        icon: Icons.timer_rounded,
                        value: _formatDuration(elapsed),
                        label: '시간',
                        color: AppColors.text1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── 경로 지도 ──
                if (latLngs.length >= 2)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 220,
                      child: _RouteMap(latLngs: latLngs),
                    ),
                  ),

                const SizedBox(height: 16),

                // ── 목표 달성 배지 ──
                if (steps >= 3000)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.green, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _badgeText(steps),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── streak 배지 ──
                if (streak >= 2) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$streak일 연속 산책 중! 내일도 함께해요',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── 버튼 ──
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '홈으로',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.walkHistory,
                    (route) => route.settings.name == AppRoutes.home,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.brownMid, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '산책 기록 보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  String _encouragement(int steps) {
    if (steps >= 8000) return '오늘 목표를 완주했어요!\n정말 대단해요 🎉';
    if (steps >= 5000) return '훌륭한 산책이었어요!\n내일도 함께해요';
    if (steps >= 3000) return '좋은 산책이었어요!\n꾸준히 걸어봐요';
    if (steps >= 1000) return '산책을 완료했어요!\n조금씩 늘려봐요';
    return '산책을 완료했어요!\n매일 조금씩이 중요해요';
  }

  String _badgeText(int steps) {
    if (steps >= 8000) return '오늘 목표 달성! 하루 8,000걸음을 넘었어요';
    if (steps >= 5000) return '5,000걸음 돌파! 훌륭한 산책이에요';
    return '3,000걸음 달성! 꾸준한 산책 습관을 만들고 있어요';
  }
}

// ── 통계 아이템 ──────────────────────────────────────────────────────

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.text3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 56,
      color: Colors.black.withValues(alpha: 0.08),
    );
  }
}

// ── 경로 지도 ────────────────────────────────────────────────────────

class _RouteMap extends StatefulWidget {
  const _RouteMap({required this.latLngs});
  final List<NLatLng> latLngs;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMap> {
  void _onMapReady(NaverMapController controller) {
    _fitRoute(controller);
    _addOverlays(controller);
  }

  void _fitRoute(NaverMapController controller) {
    if (widget.latLngs.length < 2) return;
    final bounds = NLatLngBounds.from(widget.latLngs);
    controller.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(48)),
    );
  }

  void _addOverlays(NaverMapController controller) {
    final polyline = NPolylineOverlay(
      id: 'route',
      coords: widget.latLngs,
      color: AppColors.green,
      width: 4,
    );

    final startMarker = NMarker(
      id: 'start',
      position: widget.latLngs.first,
    )..setIconTintColor(AppColors.green);

    final endMarker = NMarker(
      id: 'end',
      position: widget.latLngs.last,
    );

    controller.addOverlayAll({polyline, startMarker, endMarker});
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: widget.latLngs.first,
          zoom: 15,
        ),
        scrollGesturesEnable: false,
        zoomGesturesEnable: false,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        logoAlign: NLogoAlign.leftBottom,
      ),
      onMapReady: _onMapReady,
    );
  }
}

// ── 결과 데이터 모델 ─────────────────────────────────────────────────

class WalkResult {
  const WalkResult({
    required this.steps,
    required this.distanceKm,
    required this.elapsed,
    required this.dogName,
    this.routePoints = const [],
    this.streak = 0,
  });

  final int steps;
  final double distanceKm;
  final Duration elapsed;
  final String dogName;
  final List<Map<String, double>> routePoints;
  final int streak;
}
