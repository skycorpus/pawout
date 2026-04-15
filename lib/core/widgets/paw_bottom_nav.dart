import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/colors.dart';
import 'paw_svg.dart';

/// Slots: 0=Walk  1=Alerts  2=FAB(paw)  3=Ranking  4=Profile
class PawBottomNav extends StatelessWidget {
  const PawBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.alertCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TabItem(
                index: 0,
                current: currentIndex,
                icon: _WalkIcon(active: currentIndex == 0),
                label: 'Walk',
                onTap: onTap,
              ),
              _TabItem(
                index: 1,
                current: currentIndex,
                icon: _AlertIcon(active: currentIndex == 1, count: alertCount),
                label: 'Alerts',
                onTap: onTap,
              ),
              _PawFab(onTap: () => onTap(2)),
              _TabItem(
                index: 3,
                current: currentIndex,
                icon: Icon(
                  Icons.emoji_events_outlined,
                  size: 24,
                  color: currentIndex == 3 ? AppColors.green : AppColors.text3,
                ),
                label: 'Ranking',
                onTap: onTap,
              ),
              _TabItem(
                index: 4,
                current: currentIndex,
                icon: Icon(
                  Icons.person_outline,
                  size: 24,
                  color: currentIndex == 4 ? AppColors.green : AppColors.text3,
                ),
                label: 'Profile',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int current;
  final Widget icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 56,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.green : AppColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkIcon extends StatelessWidget {
  const _WalkIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.directions_walk,
      size: 26,
      color: active ? AppColors.green : AppColors.text3,
    );
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon({required this.active, required this.count});

  final bool active;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications_none,
          size: 24,
          color: active ? AppColors.green : AppColors.text3,
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -3,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PawFab extends StatefulWidget {
  const _PawFab({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PawFab> createState() => _PawFabState();
}

class _PawFabState extends State<_PawFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, child) {
            final shadowBlur = 8.0 + _glowAnim.value * 10.0;
            return Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.pawFabGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brownDark
                        .withValues(alpha: 0.55 + _glowAnim.value * 0.2),
                    blurRadius: shadowBlur,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9C7B72),
                    Color(0xFF8D6E63),
                    Color(0xFF6D4C41),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(child: _PawIcon()),
            ),
          ),
        ),
      ),
    );
  }
}

class _PawIcon extends StatelessWidget {
  const _PawIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      kFabPawSvg,
      width: 34,
      height: 34,
    );
  }
}
