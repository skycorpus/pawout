import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../common_code/providers/common_code_provider.dart';
import '../../walk/providers/walk_provider.dart';
import '../models/badge_model.dart';
import '../models/dog_model.dart';
import '../providers/dog_provider.dart';

class DogDetailScreen extends StatefulWidget {
  const DogDetailScreen({super.key});

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dog = ModalRoute.of(context)?.settings.arguments as Dog?;
      if (dog?.id != null) {
        context.read<WalkProvider>().fetchWalks([dog!.id!]);
      }
      context.read<CommonCodeProvider>().fetchGroup('BREED');
    });
  }

  @override
  Widget build(BuildContext context) {
    final dog = ModalRoute.of(context)?.settings.arguments as Dog?;
    if (dog == null) {
      return const Scaffold(body: Center(child: Text('강아지 정보를 찾을 수 없습니다.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<WalkProvider, CommonCodeProvider>(
          builder: (context, walkProvider, codeProvider, _) {
            final dogWalks = walkProvider.walks
                .where((w) => dog.id != null && w.dogIds.contains(dog.id))
                .toList();
            final now = DateTime.now();
            final monthWalks = dogWalks
                .where((w) =>
                    w.startTime.year == now.year &&
                    w.startTime.month == now.month)
                .toList();
            final totalKm = dogWalks.fold(
                0.0, (sum, w) => sum + w.distanceKm);
            final breedName =
                codeProvider.getCodeName('BREED', dog.breed);

            return CustomScrollView(
              slivers: [
                // ── 뒤로가기 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left,
                              color: AppColors.green, size: 20),
                          Text(
                            'My dogs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── 히어로 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _HeroCard(dog: dog, breedName: breedName),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // ── 3열 통계 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '${monthWalks.length}',
                            label: '이달 산책',
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _StatCard(
                            value: totalKm.toStringAsFixed(1),
                            label: '누적 거리 (km)',
                            color: AppColors.text1,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _StatCard(
                            value: '${dog.weight}',
                            label: '체중 (kg)',
                            color: AppColors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // ── 기본 정보 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionLabel(label: '기본 정보'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _InfoList(rows: [
                      _InfoRow(
                        label: '성별',
                        value: dog.gender == 'male' ? '수컷' : '암컷',
                      ),
                      _InfoRow(
                        label: '중성화',
                        value: dog.isNeutered ? '예' : '아니오',
                        valueColor: dog.isNeutered
                            ? AppColors.greenDark
                            : null,
                      ),
                      _InfoRow(
                        label: '생년월일',
                        value:
                            '${dog.birthDate.year}년 ${dog.birthDate.month}월 ${dog.birthDate.day}일',
                      ),
                      _InfoRow(
                        label: '나이',
                        value: '${dog.age}살',
                      ),
                      if (dog.chipNumber != null &&
                          dog.chipNumber!.isNotEmpty)
                        _InfoRow(
                          label: '동물등록번호',
                          value: _maskChip(dog.chipNumber!),
                        ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── 뱃지 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionLabel(label: '뱃지'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DogBadgeGrid(
                      badges: DogBadgeSystem.evaluate(
                        dogWalks,
                        walkProvider.currentStreak,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── CTA 버튼 ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Start walk
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.walkStart),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.green
                                      .withValues(alpha: 0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.pets,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 7),
                                Text(
                                  '${dog.name}와 산책 시작',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Edit profile
                        GestureDetector(
                          onTap: () async {
                            final updated = await Navigator.pushNamed(
                              context,
                              AppRoutes.dogEdit,
                              arguments: dog,
                            );
                            if (updated == true && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.brownMid,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '프로필 수정',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brownDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 가족 초대
                        GestureDetector(
                          onTap: () => _showInviteDialog(context, dog),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.green,
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group_add_outlined,
                                      color: AppColors.green, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    '가족 초대',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showInviteDialog(BuildContext context, Dog dog) async {
    if (dog.id == null) return;
    final dogProvider = context.read<DogProvider>();
    final code = await dogProvider.generateInviteCode(dog.id!);
    if (!context.mounted) return;

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dogProvider.errorMessage ?? '초대 코드 생성에 실패했습니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '가족 초대',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '아래 코드를 가족에게 공유하세요\n(7일간 유효)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('코드가 클립보드에 복사되었습니다')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: AppColors.greenDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.copy, color: AppColors.green, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기', style: TextStyle(color: AppColors.text2)),
          ),
        ],
      ),
    );
  }

  String _maskChip(String chip) {
    if (chip.length < 8) return chip;
    return '${chip.substring(0, 4)}*******${chip.substring(chip.length - 4)}';
  }
}

// ── 히어로 카드 ──────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.dog, required this.breedName});

  final Dog dog;
  final String breedName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF0D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.brown.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 원형 이미지
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brownLight,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brown.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  image: dog.profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(dog.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: dog.profileImageUrl == null
                    ? const Icon(Icons.pets,
                        color: AppColors.brown, size: 40)
                    : null,
              ),
              // 발바닥 뱃지
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.brownDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.pets,
                      color: Colors.white, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            dog.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$breedName · ${dog.age}살',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // Active 뱃지
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Active & healthy',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 통계 카드 ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.text3,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── 섹션 레이블 ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.text1,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ── 뱃지 그리드 ──────────────────────────────────────────────────────

class _DogBadgeGrid extends StatelessWidget {
  const _DogBadgeGrid({required this.badges});
  final List<DogBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: badges.map((badge) => _DogBadgeChip(badge: badge)).toList(),
      ),
    );
  }
}

class _DogBadgeChip extends StatelessWidget {
  const _DogBadgeChip({required this.badge});
  final DogBadge badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badge.earned ? AppColors.greenLight : AppColors.brownLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: badge.earned ? AppColors.green : AppColors.brownMid,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              badge.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badge.earned ? AppColors.greenDark : AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 정보 리스트 ──────────────────────────────────────────────────────

class _InfoList extends StatelessWidget {
  const _InfoList({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < rows.length - 1)
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        color: Colors.black.withValues(alpha: 0.05),
                        indent: 13,
                        endIndent: 13,
                      ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.text2),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}
