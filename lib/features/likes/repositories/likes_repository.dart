import 'package:supabase_flutter/supabase_flutter.dart';

class LikesRepository {
  LikesRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<Set<int>> fetchMyLikes(String userId) async {
    final response =
        await _supabase.from('likes').select('dog_id').eq('user_id', userId);

    return (response as List).map((e) => e['dog_id'] as int).toSet();
  }

  Future<Map<int, int>> fetchLikeCounts(List<int> dogIds) async {
    final response =
        await _supabase.from('likes').select('dog_id').inFilter('dog_id', dogIds);

    final counts = <int, int>{};
    for (final row in response as List) {
      final dogId = row['dog_id'] as int;
      counts[dogId] = (counts[dogId] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> addLike({
    required String userId,
    required int dogId,
  }) async {
    await _supabase.from('likes').insert({
      'user_id': userId,
      'dog_id': dogId,
    });
  }

  Future<void> removeLike({
    required String userId,
    required int dogId,
  }) async {
    await _supabase
        .from('likes')
        .delete()
        .eq('user_id', userId)
        .eq('dog_id', dogId);
  }
}
