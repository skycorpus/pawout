import 'package:flutter/foundation.dart';

import '../repositories/likes_repository.dart';

class LikesProvider extends ChangeNotifier {
  LikesProvider({LikesRepository? repository})
      : _repository = repository ?? LikesRepository();

  final LikesRepository _repository;
  Set<int> _likedDogIds = {};
  Map<int, int> _likeCounts = {};

  bool isLiked(int dogId) => _likedDogIds.contains(dogId);
  int getLikeCount(int dogId) => _likeCounts[dogId] ?? 0;

  Future<void> fetchMyLikes() async {
    final userId = _repository.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      _likedDogIds = await _repository.fetchMyLikes(userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchLikeCounts(List<int> dogIds) async {
    if (dogIds.isEmpty) {
      return;
    }

    try {
      final counts = await _repository.fetchLikeCounts(dogIds);
      _likeCounts = {..._likeCounts, ...counts};
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleLike(int dogId) async {
    final userId = _repository.currentUserId;
    if (userId == null) {
      return;
    }

    final wasLiked = _likedDogIds.contains(dogId);

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
        await _repository.removeLike(userId: userId, dogId: dogId);
      } else {
        await _repository.addLike(userId: userId, dogId: dogId);
      }
    } catch (_) {
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
