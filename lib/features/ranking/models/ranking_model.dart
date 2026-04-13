class RankingEntry {
  final int id;
  final int dogId;
  final String dogName;
  final String? dogImageUrl;
  final String ownerName;
  final String? ownerId;
  final DateTime date;
  final int totalSteps;
  final double totalDistanceKm;
  final int? rank;

  RankingEntry({
    required this.id,
    required this.dogId,
    required this.dogName,
    this.dogImageUrl,
    required this.ownerName,
    this.ownerId,
    required this.date,
    required this.totalSteps,
    required this.totalDistanceKm,
    this.rank,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    final dog = json['dogs'] as Map<String, dynamic>?;
    final profile = dog?['profiles'] as Map<String, dynamic>?;
    return RankingEntry(
      id: json['id'] as int,
      dogId: json['dog_id'] as int,
      dogName: dog?['name'] as String? ?? '알 수 없음',
      dogImageUrl: dog?['profile_image_url'] as String?,
      ownerName: profile?['name'] as String? ?? '알 수 없음',
      ownerId: dog?['user_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      totalSteps: json['total_steps'] as int? ?? 0,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int?,
    );
  }
}
