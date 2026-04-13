import 'package:flutter_test/flutter_test.dart';
import 'package:pawout/features/common_code/models/common_code_model.dart';
import 'package:pawout/features/common_code/providers/common_code_provider.dart';
import 'package:pawout/features/common_code/repositories/common_code_repository.dart';
import 'package:pawout/features/dog_profile/models/dog_model.dart';
import 'package:pawout/features/follows/providers/follows_provider.dart';
import 'package:pawout/features/follows/repositories/follows_repository.dart';
import 'package:pawout/features/likes/providers/likes_provider.dart';
import 'package:pawout/features/likes/repositories/likes_repository.dart';

class FakeCommonCodeRepository extends CommonCodeRepository {
  FakeCommonCodeRepository(this.codes);

  final List<CommonCode> codes;
  int fetchCount = 0;

  @override
  Future<List<CommonCode>> fetchGroup(String groupCode) async {
    fetchCount++;
    return codes;
  }
}

class FakeLikesRepository extends LikesRepository {
  FakeLikesRepository({
    this.userId = 'user-1',
    this.failOnAdd = false,
    this.failOnRemove = false,
  });

  final String? userId;
  final bool failOnAdd;
  final bool failOnRemove;

  @override
  String? get currentUserId => userId;

  @override
  Future<Set<int>> fetchMyLikes(String userId) async => {1, 3};

  @override
  Future<Map<int, int>> fetchLikeCounts(List<int> dogIds) async {
    return {for (final id in dogIds) id: id * 10};
  }

  @override
  Future<void> addLike({required String userId, required int dogId}) async {
    if (failOnAdd) {
      throw Exception('add failed');
    }
  }

  @override
  Future<void> removeLike({required String userId, required int dogId}) async {
    if (failOnRemove) {
      throw Exception('remove failed');
    }
  }
}

class FakeFollowsRepository extends FollowsRepository {
  FakeFollowsRepository({
    this.userId = 'me',
    this.failOnAdd = false,
    this.failOnRemove = false,
  });

  final String? userId;
  final bool failOnAdd;
  final bool failOnRemove;

  @override
  String? get currentUserId => userId;

  @override
  Future<Set<String>> fetchMyFollows(String userId) async => {'alpha', 'beta'};

  @override
  Future<({int followersCount, int followingCount})> fetchMyCounts(
    String userId,
  ) async {
    return (followersCount: 7, followingCount: 2);
  }

  @override
  Future<void> addFollow({
    required String followerId,
    required String followingId,
  }) async {
    if (failOnAdd) {
      throw Exception('add failed');
    }
  }

  @override
  Future<void> removeFollow({
    required String followerId,
    required String followingId,
  }) async {
    if (failOnRemove) {
      throw Exception('remove failed');
    }
  }
}

void main() {
  group('Dog model', () {
    test('age is calculated from birth date', () {
      final now = DateTime.now();
      final dog = Dog(
        name: 'Milo',
        breed: 'POODLE',
        birthDate: DateTime(now.year - 3, now.month, now.day),
        gender: 'male',
        weight: 4.2,
        userId: 'user-1',
      );

      expect(dog.age, 3);
    });
  });

  group('CommonCodeProvider', () {
    test('fetches once and resolves code name from cache', () async {
      final repo = FakeCommonCodeRepository([
        CommonCode(
          groupCode: 'BREED',
          code: 'POODLE',
          codeName: 'Poodle',
          sortOrder: 1,
        ),
      ]);
      final provider = CommonCodeProvider(repository: repo);

      await provider.fetchGroup('BREED');
      await provider.fetchGroup('BREED');

      expect(repo.fetchCount, 1);
      expect(provider.getCodeName('BREED', 'POODLE'), 'Poodle');
      expect(provider.getCodeName('BREED', 'UNKNOWN'), 'UNKNOWN');
    });
  });

  group('LikesProvider', () {
    test('loads likes and counts from repository', () async {
      final provider = LikesProvider(repository: FakeLikesRepository());

      await provider.fetchMyLikes();
      await provider.fetchLikeCounts([1, 2]);

      expect(provider.isLiked(1), isTrue);
      expect(provider.isLiked(2), isFalse);
      expect(provider.getLikeCount(1), 10);
      expect(provider.getLikeCount(2), 20);
    });

    test('rolls back optimistic like when repository add fails', () async {
      final provider = LikesProvider(
        repository: FakeLikesRepository(failOnAdd: true),
      );

      await provider.toggleLike(9);

      expect(provider.isLiked(9), isFalse);
      expect(provider.getLikeCount(9), 0);
    });
  });

  group('FollowsProvider', () {
    test('loads follow ids and counts from repository', () async {
      final provider = FollowsProvider(repository: FakeFollowsRepository());

      await provider.fetchMyFollows();
      await provider.fetchMyCounts();

      expect(provider.isFollowing('alpha'), isTrue);
      expect(provider.isFollowing('gamma'), isFalse);
      expect(provider.followersCount, 7);
      expect(provider.followingCount, 2);
    });

    test('rolls back optimistic unfollow when repository remove fails', () async {
      final provider = FollowsProvider(
        repository: FakeFollowsRepository(failOnRemove: true),
      );

      await provider.fetchMyFollows();
      await provider.fetchMyCounts();
      await provider.toggleFollow('alpha');

      expect(provider.isFollowing('alpha'), isTrue);
      expect(provider.followingCount, 2);
    });
  });
}
