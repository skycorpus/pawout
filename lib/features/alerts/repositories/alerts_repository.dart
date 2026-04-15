import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alert_model.dart';

class AlertsRepository {
  AlertsRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// 내 강아지에 달린 좋아요 + 나를 팔로우한 사람 목록을 합쳐 반환
  Future<List<AlertModel>> fetchAlerts({
    required List<int> myDogIds,
    required String myUserId,
    int limit = 30,
  }) async {
    final results = <AlertModel>[];

    // ── 좋아요 알림 ──────────────────────────────────────────────────
    if (myDogIds.isNotEmpty) {
      final likeRows = await _supabase
          .from('likes')
          .select('created_at, profiles!user_id(name), dogs(name)')
          .inFilter('dog_id', myDogIds)
          .neq('user_id', myUserId) // 내가 누른 좋아요 제외
          .order('created_at', ascending: false)
          .limit(limit);

      for (final row in likeRows as List) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final dog = row['dogs'] as Map<String, dynamic>?;
        results.add(AlertModel(
          type: AlertType.like,
          actorName: profile?['name'] as String? ?? '알 수 없음',
          dogName: dog?['name'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
        ));
      }
    }

    // ── 팔로우 알림 ──────────────────────────────────────────────────
    final followRows = await _supabase
        .from('follows')
        .select('created_at, profiles!follower_id(name)')
        .eq('following_id', myUserId)
        .order('created_at', ascending: false)
        .limit(limit);

    for (final row in followRows as List) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      results.add(AlertModel(
        type: AlertType.follow,
        actorName: profile?['name'] as String? ?? '알 수 없음',
        createdAt: DateTime.parse(row['created_at'] as String),
      ));
    }

    // 최신순 정렬
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.take(limit).toList();
  }
}