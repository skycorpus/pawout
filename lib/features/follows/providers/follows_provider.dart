import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowsProvider extends ChangeNotifier {
  Set<String> _followingIds = {}; // 내가 팔로우하는 user ID 목록
  int _followersCount = 0;
  int _followingCount = 0;

  bool isFollowing(String userId) => _followingIds.contains(userId);
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;

  final _supabase = Supabase.instance.client;

  // 내가 팔로우하는 목록 조회
  Future<void> fetchMyFollows() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final response = await _supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', myId);

      _followingIds =
          (response as List).map((e) => e['following_id'] as String).toSet();
      notifyListeners();
    } catch (_) {}
  }

  // 내 팔로워/팔로잉 수 조회
  Future<void> fetchMyCounts() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final followers = await _supabase
          .from('follows')
          .select('id')
          .eq('following_id', myId);

      final following = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', myId);

      _followersCount = (followers as List).length;
      _followingCount = (following as List).length;
      notifyListeners();
    } catch (_) {}
  }

  // 팔로우 토글 (낙관적 업데이트)
  Future<void> toggleFollow(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || myId == targetUserId) return;

    final wasFollowing = _followingIds.contains(targetUserId);

    // 즉시 UI 반영
    if (wasFollowing) {
      _followingIds.remove(targetUserId);
      _followingCount = (_followingCount - 1).clamp(0, 999999);
    } else {
      _followingIds.add(targetUserId);
      _followingCount++;
    }
    notifyListeners();

    try {
      if (wasFollowing) {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', myId)
            .eq('following_id', targetUserId);
      } else {
        await _supabase.from('follows').insert({
          'follower_id': myId,
          'following_id': targetUserId,
        });
      }
    } catch (_) {
      // 실패 시 롤백
      if (wasFollowing) {
        _followingIds.add(targetUserId);
        _followingCount++;
      } else {
        _followingIds.remove(targetUserId);
        _followingCount = (_followingCount - 1).clamp(0, 999999);
      }
      notifyListeners();
    }
  }
}
