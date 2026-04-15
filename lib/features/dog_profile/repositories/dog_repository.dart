import 'dart:io';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dog_model.dart';

class DogRepository {
  DogRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String _toDateString(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

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
          'birth_date': _toDateString(birthDate),
          'gender': gender,
          'weight': weight,
          'is_neutered': isNeutered,
          'chip_number': chipNumber,
          'profile_image_url': profileImageUrl,
          'user_id': _currentUserId,
          'created_by': _currentUserId,
        })
        .select()
        .single();

    final dog = Dog.fromJson(response);

    await _supabase.from('dog_members').upsert(
      {
        'dog_id': dog.id,
        'user_id': _currentUserId,
        'role': 'owner',
        'is_primary': true,
      },
      onConflict: 'dog_id,user_id',
    );

    return dog;
  }

  Future<List<Dog>> fetchDogs() async {
    final membershipRows = await _supabase
        .from('dog_members')
        .select('dog_id')
        .eq('user_id', _currentUserId);

    final dogIds = (membershipRows as List)
        .map((row) => row['dog_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    if (dogIds.isEmpty) {
      final fallback =
          await _supabase.from('dogs').select().eq('user_id', _currentUserId);
      return (fallback as List).map((e) => Dog.fromJson(e)).toList();
    }

    final response = await _supabase
        .from('dogs')
        .select()
        .inFilter('id', dogIds)
        .order('id');

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

  /// 강아지 초대 코드 생성 (이미 유효한 코드가 있으면 재사용)
  Future<String> generateInviteCode(int dogId) async {
    // 기존 유효 코드 조회
    final existing = await _supabase
        .from('dog_invites')
        .select('invite_code')
        .eq('dog_id', dogId)
        .eq('created_by', _currentUserId)
        .isFilter('used_by', null)
        .gt('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (existing != null) {
      return existing['invite_code'] as String;
    }

    // 새 코드 생성 (8자리 영숫자 대문자)
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    final code = List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();

    await _supabase.from('dog_invites').insert({
      'dog_id': dogId,
      'invite_code': code,
      'created_by': _currentUserId,
    });

    return code;
  }

  /// 초대 코드로 가족 참여
  Future<Dog> joinByInviteCode(String code) async {
    final row = await _supabase
        .from('dog_invites')
        .select('id, dog_id, used_by, expires_at')
        .eq('invite_code', code.toUpperCase().trim())
        .maybeSingle();

    if (row == null) throw Exception('유효하지 않은 초대 코드입니다');
    if (row['used_by'] != null) throw Exception('이미 사용된 초대 코드입니다');

    final expiresAt = DateTime.parse(row['expires_at'] as String);
    if (expiresAt.isBefore(DateTime.now())) {
      throw Exception('만료된 초대 코드입니다');
    }

    final dogId = row['dog_id'] as int;

    // 이미 멤버인지 확인
    final alreadyMember = await _supabase
        .from('dog_members')
        .select('id')
        .eq('dog_id', dogId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (alreadyMember != null) throw Exception('이미 이 강아지의 가족 구성원입니다');

    // dog_members에 family로 추가
    await _supabase.from('dog_members').insert({
      'dog_id': dogId,
      'user_id': _currentUserId,
      'role': 'family',
      'is_primary': false,
    });

    // 초대 코드 사용 처리
    await _supabase
        .from('dog_invites')
        .update({'used_by': _currentUserId, 'used_at': DateTime.now().toIso8601String()})
        .eq('id', row['id'] as int);

    // 강아지 정보 반환
    final dogRow = await _supabase
        .from('dogs')
        .select()
        .eq('id', dogId)
        .single();

    return Dog.fromJson(dogRow);
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
