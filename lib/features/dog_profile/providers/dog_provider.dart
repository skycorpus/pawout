import 'dart:io';

import 'package:flutter/material.dart';

import '../models/dog_model.dart';
import '../repositories/dog_repository.dart';

class DogProvider with ChangeNotifier {
  DogProvider({DogRepository? repository})
      : _repository = repository ?? DogRepository();

  final DogRepository _repository;
  List<Dog> _dogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Dog> get dogs => List.unmodifiable(_dogs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      final dog = await _repository.addDog(
        name: name,
        breed: breed,
        birthDate: birthDate,
        gender: gender,
        weight: weight,
        isNeutered: isNeutered,
        chipNumber: chipNumber,
        profileImageUrl: profileImageUrl,
      );

      _dogs.add(dog);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dogs = await _repository.fetchDogs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDog(int dogId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dog = await _repository.updateDog(dogId, updates);
      final index = _dogs.indexWhere((item) => item.id == dogId);
      if (index != -1) {
        _dogs[index] = dog;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDog(int dogId) async {
    _errorMessage = null;

    try {
      await _repository.deleteDog(dogId);
      _dogs.removeWhere((dog) => dog.id == dogId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadDogImage(File imageFile) async {
    _errorMessage = null;

    try {
      return await _repository.uploadDogImage(imageFile);
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
