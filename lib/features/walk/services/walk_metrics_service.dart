import 'package:geolocator/geolocator.dart';

class WalkMetricsState {
  const WalkMetricsState({
    required this.distanceKm,
    required this.routePoints,
    required this.lastLatitude,
    required this.lastLongitude,
  });

  final double distanceKm;
  final List<Map<String, double>> routePoints;
  final double? lastLatitude;
  final double? lastLongitude;
}

class WalkMetricsService {
  const WalkMetricsService();

  WalkMetricsState initialState() {
    return const WalkMetricsState(
      distanceKm: 0,
      routePoints: [],
      lastLatitude: null,
      lastLongitude: null,
    );
  }

  WalkMetricsState appendPoint({
    required WalkMetricsState current,
    required double latitude,
    required double longitude,
  }) {
    var nextDistanceKm = current.distanceKm;

    if (current.lastLatitude != null && current.lastLongitude != null) {
      final meters = Geolocator.distanceBetween(
        current.lastLatitude!,
        current.lastLongitude!,
        latitude,
        longitude,
      );
      nextDistanceKm += meters / 1000;
    }

    return WalkMetricsState(
      distanceKm: nextDistanceKm,
      routePoints: [
        ...current.routePoints,
        {'lat': latitude, 'lng': longitude},
      ],
      lastLatitude: latitude,
      lastLongitude: longitude,
    );
  }
}
