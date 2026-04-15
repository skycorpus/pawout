import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
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

  Future<void> _showJoinDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '코드로 가족 참여',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '초대 코드를 입력하면\n해당 강아지의 가족으로 참여합니다',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text2, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXXXXXX',
                  hintStyle: TextStyle(
                    color: AppColors.text3,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                  ),
                  filled: true,
                  fillColor: AppColors.greenLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.green, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '코드를 입력해주세요' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('취소', style: TextStyle(color: AppColors.text2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              final dogProvider = context.read<DogProvider>();
              final success =
                  await dogProvider.joinByInviteCode(controller.text.trim());

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '가족으로 참여했습니다!'
                        : (dogProvider.errorMessage ?? '참여에 실패했습니다'),
                  ),
                  backgroundColor:
                      success ? AppColors.green : AppColors.error,
                ),
              );
            },
            child: const Text('참여'),
          ),
        ],
      ),
    );

    controller.dispose();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '내 강아지',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined, color: AppColors.green),
            tooltip: '코드로 참여',
            onPressed: () => _showJoinDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dogProvider = context.read<DogProvider>();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DogRegisterScreen()),
          );
          if (result == true && mounted) {
            dogProvider.fetchDogs();
          }
        },
        backgroundColor: AppColors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, _) {
          if (dogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }

          if (dogProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    dogProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.text2),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dogProvider.fetchDogs(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (dogProvider.dogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: AppColors.green),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 강아지가 없어요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '아래 + 버튼으로 강아지를 등록해보세요',
                    style: TextStyle(color: AppColors.text2),
                  ),
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
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.dogDetail,
                    arguments: dog,
                  ),
                  child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.greenLight,
                      backgroundImage: dog.profileImageUrl != null
                          ? NetworkImage(dog.profileImageUrl!)
                          : null,
                      child: dog.profileImageUrl == null
                          ? const Icon(Icons.pets,
                              color: AppColors.green, size: 28)
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
