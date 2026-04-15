import '../../walk/models/walk_model.dart';

enum DogBadgeType {
  firstWalk,
  walks10,
  walks50,
  dist10km,
  dist50km,
  steps10k,
  steps100k,
  streak7,
  streak30,
}

class DogBadge {
  const DogBadge({
    required this.type,
    required this.emoji,
    required this.label,
    required this.description,
    required this.earned,
  });

  final DogBadgeType type;
  final String emoji;
  final String label;
  final String description;
  final bool earned;

  DogBadge copyWith({bool? earned}) => DogBadge(
        type: type,
        emoji: emoji,
        label: label,
        description: description,
        earned: earned ?? this.earned,
      );
}

class DogBadgeSystem {
  static const _definitions = [
    DogBadge(
      type: DogBadgeType.firstWalk,
      emoji: '🐾',
      label: '첫 산책',
      description: '첫 번째 산책 완료',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.walks10,
      emoji: '👟',
      label: '꾸준한 발걸음',
      description: '산책 10회 완료',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.walks50,
      emoji: '🏃',
      label: '산책 마니아',
      description: '산책 50회 완료',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.dist10km,
      emoji: '📍',
      label: '10km 돌파',
      description: '누적 거리 10km 달성',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.dist50km,
      emoji: '🗺️',
      label: '50km 탐험가',
      description: '누적 거리 50km 달성',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.steps10k,
      emoji: '👣',
      label: '만 걸음',
      description: '누적 걸음수 10,000 달성',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.steps100k,
      emoji: '🚶',
      label: '십만 걸음',
      description: '누적 걸음수 100,000 달성',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.streak7,
      emoji: '🔥',
      label: '7일 연속',
      description: '7일 연속 산책 달성',
      earned: false,
    ),
    DogBadge(
      type: DogBadgeType.streak30,
      emoji: '🏆',
      label: '30일 연속',
      description: '30일 연속 산책 달성',
      earned: false,
    ),
  ];

  /// walks: 해당 강아지의 완료된 산책 목록, streak: 현재 연속 산책일
  static List<DogBadge> evaluate(List<Walk> walks, int streak) {
    final count = walks.length;
    final totalDist = walks.fold(0.0, (sum, w) => sum + w.distanceKm);
    final totalSteps = walks.fold(0, (sum, w) => sum + w.steps);

    return _definitions.map((badge) {
      final earned = switch (badge.type) {
        DogBadgeType.firstWalk => count >= 1,
        DogBadgeType.walks10 => count >= 10,
        DogBadgeType.walks50 => count >= 50,
        DogBadgeType.dist10km => totalDist >= 10.0,
        DogBadgeType.dist50km => totalDist >= 50.0,
        DogBadgeType.steps10k => totalSteps >= 10000,
        DogBadgeType.steps100k => totalSteps >= 100000,
        DogBadgeType.streak7 => streak >= 7,
        DogBadgeType.streak30 => streak >= 30,
      };
      return badge.copyWith(earned: earned);
    }).toList();
  }
}
