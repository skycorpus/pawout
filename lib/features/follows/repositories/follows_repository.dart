import 'package:supabase_flutter/supabase_flutter.dart';

class FollowsRepository {
  FollowsRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<Set<String>> fetchMyFollows(String userId) async {
    final response = await _supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    return (response as List).map((e) => e['following_id'] as String).toSet();
  }

  Future<({int followersCount, int followingCount})> fetchMyCounts(
    String userId,
  ) async {
    final followers =
        await _supabase.from('follows').select('id').eq('following_id', userId);
    final following =
        await _supabase.from('follows').select('id').eq('follower_id', userId);

    return (
      followersCount: (followers as List).length,
      followingCount: (following as List).length,
    );
  }

  Future<void> addFollow({
    required String followerId,
    required String followingId,
  }) async {
    await _supabase.from('follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });
  }

  Future<void> removeFollow({
    required String followerId,
    required String followingId,
  }) async {
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }
}
