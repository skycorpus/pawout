import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/feed_item_model.dart';

class FeedRepository {
  FeedRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// 다른 유저들의 최근 산책 피드를 반환.
  /// walks → dogs(name, profile_image_url, user_id, profiles!user_id(name))
  Future<List<FeedItem>> fetchFeed({
    required String myUserId,
    int limit = 20,
  }) async {
    final rows = await _supabase
        .from('walks')
        .select(
          'id, start_time, end_time, distance_km, steps, '
          'dogs(name, profile_image_url, user_id, profiles!user_id(name))',
        )
        .not('end_time', 'is', null)
        .order('end_time', ascending: false)
        .limit(limit + 10); // 내 기록 제외 후 limit 맞추기 위해 여유분 요청

    final items = <FeedItem>[];
    for (final row in rows as List) {
      final dog = row['dogs'] as Map<String, dynamic>?;
      if (dog == null) continue;

      final ownerId = dog['user_id'] as String?;
      if (ownerId == myUserId) continue; // 내 기록 제외

      final profile = dog['profiles'] as Map<String, dynamic>?;
      final endTime = DateTime.parse(row['end_time'] as String);
      final startTime = DateTime.parse(row['start_time'] as String);

      items.add(FeedItem(
        walkId: row['id'] as int,
        ownerName: profile?['name'] as String? ?? '알 수 없음',
        dogName: dog['name'] as String? ?? '',
        dogImageUrl: dog['profile_image_url'] as String?,
        distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0.0,
        steps: row['steps'] as int? ?? 0,
        endTime: endTime,
        elapsed: endTime.difference(startTime),
      ));

      if (items.length >= limit) break;
    }

    return items;
  }
}
