import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/routes.dart';
import '../../dog_profile/models/dog_model.dart';
import '../../dog_profile/providers/dog_provider.dart';
import '../providers/walk_provider.dart';

class WalkStartScreen extends StatefulWidget {
  const WalkStartScreen({super.key});

  @override
  State<WalkStartScreen> createState() => _WalkStartScreenState();
}

class _WalkStartScreenState extends State<WalkStartScreen> {
  Dog? _selectedDog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DogProvider>().fetchDogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('산책 시작', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, _) {
          if (dogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
            );
          }

          if (dogProvider.dogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: Color(0xFFFF6B9D)),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 강아지가 없습니다.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '먼저 강아지를 등록해주세요.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.dogList),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('강아지 등록하러 가기'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '어떤 강아지와 산책할까요?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: dogProvider.dogs.length,
                    itemBuilder: (context, index) {
                      final dog = dogProvider.dogs[index];
                      final isSelected = _selectedDog?.id == dog.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDog = dog),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B9D).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B9D)
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    const Color(0xFFFF6B9D).withOpacity(0.1),
                                backgroundImage: dog.profileImageUrl != null
                                    ? NetworkImage(dog.profileImageUrl!)
                                    : null,
                                child: dog.profileImageUrl == null
                                    ? const Icon(
                                        Icons.pets,
                                        color: Color(0xFFFF6B9D),
                                        size: 28,
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${dog.breed} · ${dog.age}살',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF6B9D),
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
                    if (walkProvider.errorMessage == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        walkProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                Consumer<WalkProvider>(
                  builder: (context, walkProvider, _) {
                    return ElevatedButton(
                      onPressed: _selectedDog == null || walkProvider.isLoading
                          ? null
                          : () async {
                              final success =
                                  await walkProvider.startWalk(_selectedDog!.id!);
                              if (success && mounted) {
                                Navigator.pushNamed(context, AppRoutes.walkActive);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B9D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '산책 시작!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
