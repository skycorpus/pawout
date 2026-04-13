import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikesProvider extends ChangeNotifier {
  Set<int> _likedDogIds = {};
  Map<int, int> _likeCounts = {};

  bool isLiked(int dogId) => _likedDogIds.contains(dogId);
  int getLikeCount(int dogId) => _likeCounts[dogId] ?? 0;

  final _supabase = Supabase.instance.client;

  // 내가 누른 좋아요 목록 조회
  Future<void> fetchMyLikes() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('likes')
          .select('dog_id')
          .eq('user_id', userId);

      _likedDogIds =
          (response as List).map((e) => e['dog_id'] as int).toSet();
      notifyListeners();
    } catch (_) {}
  }

  // 특정 강아지들의 좋아요 수 조회 (한 번에)
  Future<void> fetchLikeCounts(List<int> dogIds) async {
    if (dogIds.isEmpty) return;

    try {
      final response = await _supabase
          .from('likes')
          .select('dog_id')
          .inFilter('dog_id', dogIds);

      final counts = <int, int>{};
      for (final row in response as List) {
        final dogId = row['dog_id'] as int;
        counts[dogId] = (counts[dogId] ?? 0) + 1;
      }
      _likeCounts = {..._likeCounts, ...counts};
      notifyListeners();
    } catch (_) {}
  }

  // 좋아요 토글 (낙관적 업데이트)
  Future<void> toggleLike(int dogId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final wasLiked = _likedDogIds.contains(dogId);

    // 즉시 UI 반영
    if (wasLiked) {
      _likedDogIds.remove(dogId);
      _likeCounts[dogId] = (_likeCounts[dogId] ?? 1) - 1;
    } else {
      _likedDogIds.add(dogId);
      _likeCounts[dogId] = (_likeCounts[dogId] ?? 0) + 1;
    }
    notifyListeners();

    try {
      if (wasLiked) {
        await _supabase
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('dog_id', dogId);
      } else {
        await _supabase.from('likes').insert({
          'user_id': userId,
          'dog_id': dogId,
        });
      }
    } catch (_) {
      // 실패 시 롤백
      if (wasLiked) {
        _likedDogIds.add(dogId);
        _likeCounts[dogId] = (_likeCounts[dogId] ?? 0) + 1;
      } else {
        _likedDogIds.remove(dogId);
        _likeCounts[dogId] = (_likeCounts[dogId] ?? 1) - 1;
      }
      notifyListeners();
    }
  }
}
