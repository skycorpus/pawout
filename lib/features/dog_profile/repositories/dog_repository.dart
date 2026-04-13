import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dog_model.dart';

class DogRepository {
  DogRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Login is required.');
    }
    return userId;
  }

  Future<Dog> addDog({
    required String name,
    required String breed,
    required DateTime birthDate,
    required String gender,
    required double weight,
    bool isNeutered = false,
    String? chipNumber,
    String? profileImageUrl,
  }) async {
    final response = await _supabase
        .from('dogs')
        .insert({
          'name': name,
          'breed': breed,
          'birth_date': birthDate.toIso8601String(),
          'gender': gender,
          'weight': weight,
          'is_neutered': isNeutered,
          'chip_number': chipNumber,
          'profile_image_url': profileImageUrl,
          'user_id': _currentUserId,
        })
        .select()
        .single();

    return Dog.fromJson(response);
  }

  Future<List<Dog>> fetchDogs() async {
    final response =
        await _supabase.from('dogs').select().eq('user_id', _currentUserId);

    return (response as List).map((e) => Dog.fromJson(e)).toList();
  }

  Future<Dog> updateDog(int dogId, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('dogs')
        .update(updates)
        .eq('id', dogId)
        .select()
        .single();

    return Dog.fromJson(response);
  }

  Future<void> deleteDog(int dogId) async {
    await _supabase.from('dogs').delete().eq('id', dogId);
  }

  Future<String> uploadDogImage(File imageFile) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final fileName = '$_currentUserId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from('dog-images').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('dog-images').getPublicUrl(fileName);
  }
}
