import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../common_code/providers/common_code_provider.dart';
import '../models/dog_model.dart';
import '../providers/dog_provider.dart';

class DogEditScreen extends StatefulWidget {
  const DogEditScreen({super.key});

  @override
  State<DogEditScreen> createState() => _DogEditScreenState();
}

class _DogEditScreenState extends State<DogEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _chipNumberController = TextEditingController();

  late Dog _dog;
  bool _initialized = false;

  DateTime? _selectedBirthDate;
  String _selectedGender = 'male';
  String? _selectedBreedCode;
  bool _isNeutered = false;
  File? _newProfileImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dog = ModalRoute.of(context)!.settings.arguments as Dog;
      _nameController.text = _dog.name;
      _weightController.text = _dog.weight.toString();
      _chipNumberController.text = _dog.chipNumber ?? '';
      _selectedBirthDate = _dog.birthDate;
      _selectedGender = _dog.gender;
      _selectedBreedCode = _dog.breed;
      _isNeutered = _dog.isNeutered;

      // breed 표시명 세팅 (CommonCodeProvider가 이미 로드되어 있을 가능성 있음)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final breedName = context
            .read<CommonCodeProvider>()
            .getCodeName('BREED', _dog.breed);
        _breedController.text =
            breedName.isNotEmpty ? breedName : _dog.breed;
      });

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _chipNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _newProfileImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.green,
            onPrimary: Colors.white,
            onSurface: AppColors.text1,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  Future<void> _selectBreed() async {
    final breeds =
        context.read<CommonCodeProvider>().getGroup('BREED');
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('견종 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: breeds.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(breeds[i].codeName),
              selected: breeds[i].code == _selectedBreedCode,
              selectedColor: AppColors.green,
              onTap: () => Navigator.pop(context, breeds[i].code),
            ),
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      final codeName = context
          .read<CommonCodeProvider>()
          .getCodeName('BREED', selected);
      setState(() {
        _selectedBreedCode = selected;
        _breedController.text = codeName;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      _showSnack('생년월일을 선택해주세요');
      return;
    }
    if (_selectedBreedCode == null) {
      _showSnack('견종을 선택해주세요');
      return;
    }

    final dogProvider = context.read<DogProvider>();

    // 이미지 변경 시 업로드
    String? imageUrl = _dog.profileImageUrl;
    if (_newProfileImage != null) {
      setState(() => _isUploading = true);
      imageUrl = await dogProvider.uploadDogImage(_newProfileImage!);
      setState(() => _isUploading = false);
      if (imageUrl == null && mounted) {
        _showSnack(dogProvider.errorMessage ?? '이미지 업로드 실패', isError: true);
        return;
      }
    }

    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'breed': _selectedBreedCode!,
      'birth_date': _selectedBirthDate!.toIso8601String(),
      'gender': _selectedGender,
      'weight': double.parse(_weightController.text),
      'is_neutered': _isNeutered,
      'chip_number': _chipNumberController.text.trim().isEmpty
          ? null
          : _chipNumberController.text.trim(),
      'profile_image_url': imageUrl,
    };

    final success = await dogProvider.updateDog(_dog.id!, updates);
    if (!mounted) return;

    if (success) {
      _showSnack('수정되었습니다');
      Navigator.pop(context, true);
    } else {
      _showSnack(dogProvider.errorMessage ?? '수정에 실패했습니다', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '프로필 수정',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.green),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 프로필 이미지 ──
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brownLight,
                          border:
                              Border.all(color: AppColors.green, width: 2.5),
                          image: _newProfileImage != null
                              ? DecorationImage(
                                  image: FileImage(_newProfileImage!),
                                  fit: BoxFit.cover,
                                )
                              : (_dog.profileImageUrl != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(_dog.profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: (_newProfileImage == null &&
                                _dog.profileImageUrl == null)
                            ? const Icon(Icons.pets,
                                color: AppColors.brown, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── 이름 ──
              _buildField(
                controller: _nameController,
                label: '이름',
                icon: Icons.pets,
                validator: (v) =>
                    (v == null || v.isEmpty) ? '이름을 입력해주세요' : null,
              ),
              const SizedBox(height: 14),

              // ── 견종 ──
              _buildField(
                controller: _breedController,
                label: '견종',
                icon: Icons.category_outlined,
                readOnly: true,
                onTap: _selectBreed,
                suffixIcon: Icons.arrow_drop_down,
                validator: (v) =>
                    (v == null || v.isEmpty) ? '견종을 선택해주세요' : null,
              ),
              const SizedBox(height: 14),

              // ── 생년월일 ──
              GestureDetector(
                onTap: _selectBirthDate,
                child: _InputShell(
                  label: '생년월일',
                  icon: Icons.cake_outlined,
                  child: Text(
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: TextStyle(
                      color: _selectedBirthDate != null
                          ? AppColors.text1
                          : AppColors.text3,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── 성별 ──
              _InputShell(
                label: '성별',
                icon: Icons.wc_outlined,
                child: Row(
                  children: [
                    _GenderChip(
                      label: '수컷',
                      selected: _selectedGender == 'male',
                      onTap: () =>
                          setState(() => _selectedGender = 'male'),
                    ),
                    const SizedBox(width: 8),
                    _GenderChip(
                      label: '암컷',
                      selected: _selectedGender == 'female',
                      onTap: () =>
                          setState(() => _selectedGender = 'female'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 체중 ──
              _buildField(
                controller: _weightController,
                label: '체중 (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,1}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return '체중을 입력해주세요';
                  final w = double.tryParse(v);
                  if (w == null || w <= 0) return '올바른 체중을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── 중성화 ──
              _InputShell(
                label: '중성화 여부',
                icon: Icons.medical_services_outlined,
                child: Transform.scale(
                  scale: 0.85,
                  alignment: Alignment.centerLeft,
                  child: Switch(
                    value: _isNeutered,
                    activeColor: AppColors.green,
                    onChanged: (v) => setState(() => _isNeutered = v),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── 칩번호 ──
              _buildField(
                controller: _chipNumberController,
                label: '동물등록번호 (선택)',
                icon: Icons.qr_code_outlined,
                keyboardType: TextInputType.number,
                maxLength: 15,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length != 15) {
                    return '15자리를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── 저장 버튼 ──
              Consumer<DogProvider>(
                builder: (_, dp, __) {
                  final loading = _isUploading || dp.isLoading;
                  return GestureDetector(
                    onTap: loading ? null : _handleSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: loading
                            ? null
                            : AppColors.heroGradient,
                        color: loading ? AppColors.text3 : null,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: loading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.green
                                      .withValues(alpha: 0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '수정 완료',
                                style: TextStyle(
                                  fontSize: 15,
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
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.text2, size: 20),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppColors.text3)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green),
        ),
        filled: true,
        fillColor: AppColors.white,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── 입력 껍데기 (읽기 전용 필드 공통 스타일) ────────────────────────

class _InputShell extends StatelessWidget {
  const _InputShell({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.text2, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 성별 칩 ───────────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenLight : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.text3,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.greenDark : AppColors.text2,
          ),
        ),
      ),
    );
  }
}
