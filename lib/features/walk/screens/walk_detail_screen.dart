import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../core/constants/colors.dart';
import '../models/walk_model.dart';

/// 산책 기록 상세 화면.
/// arguments: Walk
class WalkDetailScreen extends StatelessWidget {
  const WalkDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walk = ModalRoute.of(context)?.settings.arguments as Walk?;
    if (walk == null) {
      return const Scaffold(
        body: Center(child: Text('데이터를 불러올 수 없습니다.')),
      );
    }

    final latLngs = (walk.routePoints ?? [])
        .map((p) => NLatLng(p['latitude']!, p['longitude']!))
        .toList();

    final startDate = walk.startTime;
    final dateLabel =
        '${startDate.year}.${startDate.month.toString().padLeft(2, '0')}'
        '.${startDate.day.toString().padLeft(2, '0')}';
    final timeLabel =
        '${startDate.hour.toString().padLeft(2, '0')}:'
        '${startDate.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '$dateLabel $timeLabel 산책',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.text1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 통계 카드 ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCell(
                    icon: Icons.timer_rounded,
                    value: '${walk.durationMinutes}분',
                    label: '시간',
                    color: AppColors.text1,
                  ),
                  _VerticalDivider(),
                  _StatCell(
                    icon: Icons.route_rounded,
                    value: '${walk.distanceKm.toStringAsFixed(2)} km',
                    label: '거리',
                    color: AppColors.brown,
                  ),
                  _VerticalDivider(),
                  _StatCell(
                    icon: Icons.directions_walk_rounded,
                    value: _formatSteps(walk.steps),
                    label: '걸음',
                    color: AppColors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 경로 지도 ──
            if (latLngs.length >= 2) ...[
              const Text(
                '산책 경로',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 320,
                  child: _RouteMap(latLngs: latLngs),
                ),
              ),
            ] else ...[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 40, color: AppColors.text3),
                      SizedBox(height: 8),
                      Text(
                        '경로 데이터가 없습니다',
                        style: TextStyle(
                            color: AppColors.text3, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return steps.toString();
  }
}

// ── 통계 셀 ────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  const _StatCell({
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 52,
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
  NaverMapController? _mapController;

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _fitRoute();
    _addOverlays();
  }

  void _fitRoute() {
    if (widget.latLngs.length < 2) return;
    final bounds = NLatLngBounds.from(widget.latLngs);
    _mapController?.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(56)),
    );
  }

  void _addOverlays() {
    final polyline = NPolylineOverlay(
      id: 'route',
      coords: widget.latLngs,
      color: AppColors.green,
      width: 5,
    );

    final startMarker = NMarker(
      id: 'start',
      position: widget.latLngs.first,
      caption: const NOverlayCaption(text: '출발'),
    )..setIconTintColor(AppColors.green);

    final endMarker = NMarker(
      id: 'end',
      position: widget.latLngs.last,
      caption: const NOverlayCaption(text: '도착'),
    );

    _mapController?.addOverlayAll({polyline, startMarker, endMarker});
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: widget.latLngs.first,
          zoom: 15,
        ),
        scrollGesturesEnable: true,
        zoomGesturesEnable: true,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        logoAlign: NLogoAlign.leftBottom,
      ),
      onMapReady: _onMapReady,
    );
  }
}
