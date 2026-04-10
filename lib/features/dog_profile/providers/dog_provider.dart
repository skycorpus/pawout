import 'package:flutter/material.dart';
// import 'package:pawout/features/dog_profile/models/dog_model.dart';

class DogProvider with ChangeNotifier {
  List<dynamic> _dogs = []; // Dog 타입으로 나중에 변경
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get dogs => _dogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 강아지 추가
  Future<bool> addDog({
    required String name,
    required String breed,
    required DateTime birthDate,
    required String gender,
    required double weight,
    String? chipNumber,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 API 호출로 교체
      // final response = await apiService.createDog(...);

      await Future.delayed(const Duration(seconds: 1));

      // 임시 강아지 데이터 생성
      final newDog = {
        'id': _dogs.length + 1,
        'name': name,
        'breed': breed,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'weight': weight,
        'chipNumber': chipNumber,
        'profileImageUrl': profileImageUrl,
        'userId': 1, // 임시
        'createdAt': DateTime.now().toIso8601String(),
      };

      _dogs.add(newDog);
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
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1));

      // 임시 데이터
      _dogs = [
        {
          'id': 1,
          'name': '멍멍이',
          'breed': '골든 리트리버',
          'birthDate': '2020-03-15',
          'gender': 'male',
          'weight': 28.5,
          'chipNumber': '410000012345678',
        },
        {
          'id': 2,
          'name': '복실이',
          'breed': '시바견',
          'birthDate': '2021-07-20',
          'gender': 'female',
          'weight': 9.2,
          'chipNumber': null,
        },
      ];

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
      await Future.delayed(const Duration(seconds: 1));

      final index = _dogs.indexWhere((dog) => dog['id'] == dogId);
      if (index != -1) {
        _dogs[index] = {..._dogs[index], ...updates};
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
      await Future.delayed(const Duration(seconds: 1));
      _dogs.removeWhere((dog) => dog['id'] == dogId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
