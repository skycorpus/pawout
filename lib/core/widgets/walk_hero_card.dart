import 'package:flutter/material.dart';

import '../constants/colors.dart';

class WalkHeroCard extends StatelessWidget {
  const WalkHeroCard({
    super.key,
    required this.dogName,
    required this.todaySteps,
    required this.onStartWalk,
    this.streak = 0,
  });

  final String dogName;
  final int todaySteps;
  final VoidCallback onStartWalk;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(17),
      child: Stack(
        children: [
          // bg circles
          Positioned(
            top: -26,
            right: 42,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // floating paw bottom-right
          Positioned(
            right: -6,
            bottom: -6,
            child: Opacity(
              opacity: 0.13,
              child: SizedBox(
                width: 95,
                height: 95,
                child: CustomPaint(painter: _LargePawPainter()),
              ),
            ),
          ),
          // content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // active badge + streak badge
              Row(
                children: [
                  _ActiveBadge(),
                  if (streak >= 2) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '🔥 $streak일 연속',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Time for $dogName's walk!",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Start tracking your walk now',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xBDFFFFFF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // start walk button
                  GestureDetector(
                    onTap: onStartWalk,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.greenDark,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Start walk',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // today's steps
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Today's steps",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatSteps(todaySteps),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }
}

class _ActiveBadge extends StatefulWidget {
  @override
  State<_ActiveBadge> createState() => _ActiveBadgeState();
}

class _ActiveBadgeState extends State<_ActiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Opacity(
              opacity: _anim.value,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Active now',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargePawPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.65, height: h * 0.48),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.28, h * 0.48), width: w * 0.20, height: h * 0.26),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.72, h * 0.48), width: w * 0.20, height: h * 0.26),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.38, h * 0.32), width: w * 0.20, height: h * 0.26),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.62, h * 0.32), width: w * 0.20, height: h * 0.26),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LargePawPainter old) => false;
}

// ── ProgressGoalCard ─────────────────────────────────────────────────

class ProgressGoalCard extends StatelessWidget {
  const ProgressGoalCard({
    super.key,
    required this.progressFraction,
    required this.subtitle,
  });

  final double progressFraction;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final pct = (progressFraction * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's goal",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}

// ── ActivityCard ─────────────────────────────────────────────────────

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.iconBgColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.onTap,
  });

  final Color iconBgColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: _iconColor(iconBgColor)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.text3),
                  ),
                ],
              ),
            ),
            Text(
              timeLabel,
              style: const TextStyle(fontSize: 10, color: AppColors.text3),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, color: AppColors.text3, size: 16),
          ],
        ),
      ),
    );
  }

  Color _iconColor(Color bg) {
    final luminance = bg.computeLuminance();
    if (luminance > 0.5) {
      // light bg → use darker tint
      return AppColors.greenDark;
    }
    return AppColors.green;
  }
}
