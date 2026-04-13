import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dog_model.dart';

class DogProvider with ChangeNotifier {
  List<Dog> _dogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Dog> get dogs => List.unmodifiable(_dogs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _supabase = Supabase.instance.client;

  // 강아지 추가
  Future<bool> addDog({
    required String name,
    required String breed,
    required DateTime birthDate,
    required String gender,
    required double weight,
    bool isNeutered = false,
    String? chipNumber,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase.from('dogs').insert({
        'name': name,
        'breed': breed,
        'birth_date': birthDate.toIso8601String(),
        'gender': gender,
        'weight': weight,
        'is_neutered': isNeutered,
        'chip_number': chipNumber,
        'profile_image_url': profileImageUrl,
        'user_id': userId,
      }).select().single();

      _dogs.add(Dog.fromJson(response));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 강아지 목록 가져오기
  Future<void> fetchDogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('dogs')
          .select()
          .eq('user_id', userId);

      _dogs = (response as List).map((e) => Dog.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 강아지 정보 업데이트
  Future<bool> updateDog(int dogId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('dogs')
          .update(updates)
          .eq('id', dogId)
          .select()
          .single();

      final index = _dogs.indexWhere((dog) => dog.id == dogId);
      if (index != -1) {
        _dogs[index] = Dog.fromJson(response);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 강아지 삭제
  Future<bool> deleteDog(int dogId) async {
    try {
      await _supabase.from('dogs').delete().eq('id', dogId);
      _dogs.removeWhere((dog) => dog.id == dogId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 강아지 프로필 이미지 업로드
  Future<String?> uploadDogImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from('dog-images').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final url =
          _supabase.storage.from('dog-images').getPublicUrl(fileName);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
