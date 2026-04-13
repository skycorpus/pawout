import 'package:flutter/foundation.dart';

import '../repositories/follows_repository.dart';

class FollowsProvider extends ChangeNotifier {
  FollowsProvider({FollowsRepository? repository})
      : _repository = repository ?? FollowsRepository();

  final FollowsRepository _repository;
  Set<String> _followingIds = {};
  int _followersCount = 0;
  int _followingCount = 0;

  bool isFollowing(String userId) => _followingIds.contains(userId);
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;

  Future<void> fetchMyFollows() async {
    final myId = _repository.currentUserId;
    if (myId == null) {
      return;
    }

    try {
      _followingIds = await _repository.fetchMyFollows(myId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchMyCounts() async {
    final myId = _repository.currentUserId;
    if (myId == null) {
      return;
    }

    try {
      final counts = await _repository.fetchMyCounts(myId);
      _followersCount = counts.followersCount;
      _followingCount = counts.followingCount;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFollow(String targetUserId) async {
    final myId = _repository.currentUserId;
    if (myId == null || myId == targetUserId) {
      return;
    }

    final wasFollowing = _followingIds.contains(targetUserId);

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
        await _repository.removeFollow(
          followerId: myId,
          followingId: targetUserId,
        );
      } else {
        await _repository.addFollow(
          followerId: myId,
          followingId: targetUserId,
        );
      }
    } catch (_) {
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
