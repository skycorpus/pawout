import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dog_provider.dart';
import '../models/dog_model.dart';
import 'dog_register_screen.dart';
import '../../common_code/providers/common_code_provider.dart';

class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DogProvider>().fetchDogs();
    });
  }

  Future<void> _deleteDog(Dog dog) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('강아지 삭제'),
        content: Text('${dog.name}을(를) 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<DogProvider>().deleteDog(dog.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('내 강아지', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DogRegisterScreen()),
          );
          if (result == true && mounted) {
            context.read<DogProvider>().fetchDogs();
          }
        },
        backgroundColor: const Color(0xFFFF6B9D),
        child: const Icon(Icons.add, color: Colors.white),
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
                  const Text('등록된 강아지가 없어요',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('아래 + 버튼으로 강아지를 등록해보세요',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dogProvider.dogs.length,
            itemBuilder: (context, index) {
              final dog = dogProvider.dogs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                      backgroundImage: dog.profileImageUrl != null
                          ? NetworkImage(dog.profileImageUrl!)
                          : null,
                      child: dog.profileImageUrl == null
                          ? const Icon(Icons.pets,
                              color: Color(0xFFFF6B9D), size: 28)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(dog.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              if (dog.isNeutered) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.teal.shade200),
                                  ),
                                  child: Text('중성화',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.teal.shade700,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${context.read<CommonCodeProvider>().getCodeName('BREED', dog.breed)} · ${dog.age}살 · ${dog.gender == 'male' ? '남아' : '여아'}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                          Text('${dog.weight}kg',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteDog(dog),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
