class WalkModel {
  const WalkModel({
    required this.id,
    required this.startedAt,
    required this.distanceInKm,
    required this.durationInMinutes,
  });

  final String id;
  final DateTime startedAt;
  final double distanceInKm;
  final int durationInMinutes;
}
