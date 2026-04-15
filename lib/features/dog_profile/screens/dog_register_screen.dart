import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/dog_provider.dart';
import '../../common_code/providers/common_code_provider.dart';

class DogRegisterScreen extends StatefulWidget {
  const DogRegisterScreen({super.key});

  @override
  State<DogRegisterScreen> createState() => _DogRegisterScreenState();
}

class _DogRegisterScreenState extends State<DogRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _chipNumberController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedGender = 'male';
  String? _selectedBreedCode;
  bool _isNeutered = false;
  File? _profileImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommonCodeProvider>().fetchGroup('BREED');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _chipNumberController.dispose();
    super.dispose();
  }

  // 사진 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 불러오는데 실패했습니다: $e')),
      );
    }
  }

  // 생년월일 선택
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B9D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  // 견종 선택 다이얼로그 (공통코드)
  Future<void> _selectBreed() async {
    final breeds = context.read<CommonCodeProvider>().getGroup('BREED');
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('견종 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: breeds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(breeds[index].codeName),
                  onTap: () => Navigator.pop(context, breeds[index].code),
                );
              },
            ),
          ),
        );
      },
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

  // 등록 처리
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해주세요')),
      );
      return;
    }

    if (_selectedBreedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('견종을 선택해주세요')),
      );
      return;
    }

    final dogProvider = Provider.of<DogProvider>(context, listen: false);

    // 이미지 업로드
    String? imageUrl;
    if (_profileImage != null) {
      setState(() => _isUploading = true);
      imageUrl = await dogProvider.uploadDogImage(_profileImage!);
      setState(() => _isUploading = false);
      if (imageUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dogProvider.errorMessage ?? '이미지 업로드에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final success = await dogProvider.addDog(
      name: _nameController.text.trim(),
      breed: _selectedBreedCode!,
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      weight: double.parse(_weightController.text),
      isNeutered: _isNeutered,
      chipNumber: _chipNumberController.text.trim().isEmpty
          ? null
          : _chipNumberController.text.trim(),
      profileImageUrl: imageUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('강아지가 등록되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dogProvider.errorMessage ?? '등록에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('강아지 등록', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 사진
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B9D),
                        width: 3,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Color(0xFFFF6B9D),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '사진 추가',
                                style: TextStyle(
                                  color: Color(0xFFFF6B9D),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 이름
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름 *',
                  hintText: '멍멍이',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 견종
              TextFormField(
                controller: _breedController,
                readOnly: true,
                onTap: _selectBreed,
                decoration: InputDecoration(
                  labelText: '견종 *',
                  hintText: '견종을 선택하세요',
                  prefixIcon: const Icon(Icons.category),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '견종을 선택해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 생년월일
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '생년월일 *',
                    prefixIcon: const Icon(Icons.cake),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: TextStyle(
                      color: _selectedBirthDate != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 성별
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '성별 *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('남아'),
                            value: 'male',
                            groupValue: _selectedGender,
                            activeColor: const Color(0xFFFF6B9D),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('여아'),
                            value: 'female',
                            groupValue: _selectedGender,
                            activeColor: const Color(0xFFFF6B9D),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 중성화 여부
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('중성화 여부',
                        style: TextStyle(fontSize: 15)),
                    Switch(
                      value: _isNeutered,
                      activeColor: const Color(0xFFFF6B9D),
                      onChanged: (value) =>
                          setState(() => _isNeutered = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 체중
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                decoration: InputDecoration(
                  labelText: '체중 (kg) *',
                  hintText: '10.5',
                  prefixIcon: const Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '체중을 입력해주세요';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return '올바른 체중을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 동물등록번호 (선택)
              TextFormField(
                controller: _chipNumberController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: '동물등록번호 (선택)',
                  hintText: '410000012345678 (15자리)',
                  prefixIcon: const Icon(Icons.qr_code),
                  helperText: '동물등록증에 기재된 15자리 번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 15) {
                    return '동물등록번호는 15자리여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              Consumer<DogProvider>(
                builder: (context, dogProvider, _) {
                  final isLoading = _isUploading || dogProvider.isLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '등록하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 안내 문구
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '* 필수 항목입니다. 정확한 정보를 입력해주세요.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
