class Walk {
  final int? id;
  final int dogId;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final int steps;
  final List<Map<String, double>>? routePoints;
  final DateTime createdAt;

  Walk({
    this.id,
    required this.dogId,
    required this.startTime,
    this.endTime,
    this.distanceKm = 0.0,
    this.steps = 0,
    this.routePoints,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get durationMinutes =>
      (endTime ?? DateTime.now()).difference(startTime).inMinutes;

  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      id: json['id'] as int?,
      dogId: json['dog_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      steps: json['steps'] as int? ?? 0,
      routePoints: json['route_points'] != null
          ? (json['route_points'] as List)
              .map((p) => Map<String, double>.from(
                  (p as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))))
              .toList()
          : null,
      createdAt: json['i_date'] != null
          ? DateTime.parse(json['i_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dog_id': dogId,
      'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      'distance_km': distanceKm,
      'steps': steps,
      if (routePoints != null) 'route_points': routePoints,
    };
  }
}
