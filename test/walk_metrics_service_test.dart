import 'package:flutter_test/flutter_test.dart';
import 'package:pawout/features/walk/services/walk_metrics_service.dart';

void main() {
  group('WalkMetricsService', () {
    const service = WalkMetricsService();

    test('starts with empty metrics state', () {
      final state = service.initialState();

      expect(state.distanceKm, 0);
      expect(state.routePoints, isEmpty);
      expect(state.lastLatitude, isNull);
      expect(state.lastLongitude, isNull);
    });

    test('first point adds route point without distance', () {
      final state = service.appendPoint(
        current: service.initialState(),
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(state.distanceKm, 0);
      expect(state.routePoints, [
        {'lat': 37.5665, 'lng': 126.9780},
      ]);
      expect(state.lastLatitude, 37.5665);
      expect(state.lastLongitude, 126.9780);
    });

    test('second point accumulates positive distance', () {
      final first = service.appendPoint(
        current: service.initialState(),
        latitude: 37.5665,
        longitude: 126.9780,
      );
      final second = service.appendPoint(
        current: first,
        latitude: 37.5651,
        longitude: 126.98955,
      );

      expect(second.distanceKm, greaterThan(0));
      expect(second.routePoints.length, 2);
      expect(second.lastLatitude, 37.5651);
      expect(second.lastLongitude, 126.98955);
    });
  });
}
