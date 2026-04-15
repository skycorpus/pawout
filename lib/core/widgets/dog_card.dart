import 'package:flutter/material.dart';

import '../constants/colors.dart';

class DogCard extends StatelessWidget {
  const DogCard({
    super.key,
    required this.name,
    required this.breed,
    required this.age,
    required this.isActive,
    required this.headerGradient,
    required this.avatarBgColor,
    this.profileImageUrl,
    this.onTap,
  });

  final String name;
  final String breed;
  final int age;
  final bool isActive;
  final LinearGradient headerGradient;
  final Color avatarBgColor;
  final String? profileImageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 114,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 0.5),
        ),
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── header ──
                _DogCardHeader(gradient: headerGradient),
                // ── body (top padding = avatar overlap 28px + gap 4px) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 32, 11, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$breed · ${age}y',
                        style: const TextStyle(fontSize: 9, color: AppColors.text3),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      _StatusBadge(isActive: isActive),
                    ],
                  ),
                ),
              ],
            ),
            // ── floating avatar: top = 80(header) - 28(overlap) = 52 ──
            Positioned(
              top: 52,
              left: 0,
              right: 0,
              child: Center(
                child: _DogAvatar(
                  bgColor: avatarBgColor,
                  profileImageUrl: profileImageUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogCardHeader extends StatelessWidget {
  const _DogCardHeader({required this.gradient});

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // paw deco top-left
          Positioned(
            top: 4,
            left: 4,
            child: Opacity(
              opacity: 0.22,
              child: _PawMini(size: 18),
            ),
          ),
          // paw deco top-right rotated
          Positioned(
            top: 2,
            right: 6,
            child: Transform.rotate(
              angle: 0.35,
              child: Opacity(opacity: 0.15, child: _PawMini(size: 12)),
            ),
          ),
          // heart deco bottom-left
          Positioned(
            bottom: 20,
            left: 8,
            child: Opacity(
              opacity: 0.25,
              child: Icon(Icons.favorite, color: Colors.white, size: 10),
            ),
          ),
          // star deco
          Positioned(
            top: 6,
            right: 22,
            child: Opacity(
              opacity: 0.20,
              child: Icon(Icons.star, color: Colors.white, size: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PawMini extends StatelessWidget {
  const _PawMini({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PawPainter(color: Colors.white),
    );
  }
}

class _PawPainter extends CustomPainter {
  _PawPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    // palm
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.7), width: w * 0.7, height: h * 0.5), paint);
    // toes
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.27, h * 0.5), width: w * 0.22, height: h * 0.28), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.5), width: w * 0.22, height: h * 0.28), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.33), width: w * 0.22, height: h * 0.28), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.33), width: w * 0.22, height: h * 0.28), paint);
  }

  @override
  bool shouldRepaint(_PawPainter old) => old.color != color;
}

class _DogAvatar extends StatelessWidget {
  const _DogAvatar({required this.bgColor, this.profileImageUrl});
  final Color bgColor;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bgColor,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        image: profileImageUrl != null
            ? DecorationImage(
                image: NetworkImage(profileImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profileImageUrl == null
          ? const Icon(Icons.pets, color: AppColors.brown, size: 28)
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.greenLight : AppColors.brownLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? AppColors.green : AppColors.brown,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isActive ? 'Active' : 'Resting',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.greenDark : AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── card color themes ──────────────────────────────────────────────
const List<LinearGradient> kDogCardGradients = [
  LinearGradient(
    colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFF7986CB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFFFCC80), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF80DEEA), Color(0xFF4DD0E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

const List<Color> kDogAvatarBgColors = [
  Color(0xFFE8F5E9),
  Color(0xFFEFEBE9),
  Color(0xFFEDE7F6),
  Color(0xFFFFF3E0),
  Color(0xFFE0F7FA),
];
