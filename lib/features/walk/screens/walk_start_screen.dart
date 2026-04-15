import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../providers/walk_provider.dart';

class WalkStartScreen extends StatefulWidget {
  const WalkStartScreen({super.key});

  @override
  State<WalkStartScreen> createState() => _WalkStartScreenState();
}

class _WalkStartScreenState extends State<WalkStartScreen> {
  static const _prefsKey = 'last_selected_dog_ids';
  final Set<int> _selectedDogIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DogProvider>().fetchDogs();
      if (!mounted) return;

      final dogs = context.read<DogProvider>().dogs;
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);

      if (!mounted) return;

      if (saved != null && saved.isNotEmpty) {
        // 저장된 ID 중 현재 강아지 목록에 존재하는 것만 복원
        final validIds = dogs
            .where((d) => d.id != null && saved.contains(d.id.toString()))
            .map((d) => d.id!)
            .toSet();
        if (validIds.isNotEmpty) {
          setState(() => _selectedDogIds.addAll(validIds));
          return;
        }
      }

      // 저장된 선택이 없거나 유효하지 않으면 강아지 1마리일 때 자동 선택
      if (dogs.length == 1 && dogs.first.id != null) {
        setState(() => _selectedDogIds.add(dogs.first.id!));
      }
    });
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _selectedDogIds.map((id) => id.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '산책 시작',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.text1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.green),
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, _) {
          if (dogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }

          if (dogProvider.dogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 72, color: AppColors.brown),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 강아지가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '먼저 강아지를 등록해 주세요',
                    style: TextStyle(color: AppColors.text2),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.dogList),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '강아지 등록하러 가기',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '산책할 강아지를 선택하세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_selectedDogIds.length}마리 선택됨',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: dogProvider.dogs.length,
                    itemBuilder: (context, index) {
                      final dog = dogProvider.dogs[index];
                      final dogId = dog.id;
                      final isSelected =
                          dogId != null && _selectedDogIds.contains(dogId);

                      return GestureDetector(
                        onTap: dogId == null
                            ? null
                            : () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedDogIds.remove(dogId);
                                  } else {
                                    _selectedDogIds.add(dogId);
                                  }
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.greenLight
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : Colors.black.withValues(alpha: 0.08),
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: AppColors.brownLight,
                                  image: dog.profileImageUrl != null
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(dog.profileImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: dog.profileImageUrl == null
                                    ? const Icon(
                                        Icons.pets,
                                        color: AppColors.brown,
                                        size: 26,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dog.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${dog.breed} · ${dog.age}살',
                                      style: const TextStyle(
                                        color: AppColors.text2,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.text3,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Consumer<WalkProvider>(
                  builder: (context, walkProvider, _) {
                    if (walkProvider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          walkProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Consumer<WalkProvider>(
                  builder: (context, walkProvider, _) {
                    final disabled =
                        _selectedDogIds.isEmpty || walkProvider.isLoading;
                    return GestureDetector(
                      onTap: disabled
                          ? null
                          : () async {
                              await _saveSelection();
                              final success = await walkProvider
                                  .startWalk(_selectedDogIds.toList());
                              if (success && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.walkActive,
                                );
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: disabled ? null : AppColors.heroGradient,
                          color: disabled ? AppColors.text3 : null,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: disabled
                              ? []
                              : [
                                  BoxShadow(
                                    color:
                                        AppColors.green.withValues(alpha: 0.30),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: walkProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '산책 시작!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
