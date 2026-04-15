import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/walk_model.dart';

class WalkRepository {
  WalkRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<int> createWalk({
    required int primaryDogId,
    required List<int> dogIds,
    required DateTime startTime,
  }) async {
    final response = await _supabase
        .from('walks')
        .insert({
          'dog_id': primaryDogId,
          'start_time': startTime.toIso8601String(),
        })
        .select('id')
        .single();

    final walkId = response['id'] as int;

    await _supabase.from('walk_dogs').insert(
      dogIds.asMap().entries.map((entry) {
        return {
          'walk_id': walkId,
          'dog_id': entry.value,
          'display_order': entry.key,
        };
      }).toList(),
    );

    return walkId;
  }

  Future<void> completeWalk({
    required int walkId,
    required DateTime endTime,
    required double distanceKm,
    required int steps,
    required List<Map<String, double>> routePoints,
  }) async {
    await _supabase
        .from('walks')
        .update({
          'end_time': endTime.toIso8601String(),
          'distance_km': double.parse(distanceKm.toStringAsFixed(2)),
          'steps': steps,
          'route_points': routePoints,
        })
        .eq('id', walkId);
  }

  Future<void> cancelWalk(int walkId) async {
    await _supabase.from('walk_dogs').delete().eq('walk_id', walkId);
    await _supabase.from('walks').delete().eq('id', walkId);
  }

  Future<List<Walk>> fetchWalks(List<int> dogIds) async {
    final linkedRows = await _supabase
        .from('walk_dogs')
        .select('walk_id')
        .inFilter('dog_id', dogIds);

    final linkedWalkIds = (linkedRows as List)
        .map((row) => row['walk_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final legacyRows = await _supabase
        .from('walks')
        .select()
        .inFilter('dog_id', dogIds)
        .not('end_time', 'is', null);

    final legacyWalks =
        (legacyRows as List).map((e) => Walk.fromJson(e)).toList();

    if (linkedWalkIds.isEmpty) {
      legacyWalks.sort((a, b) => b.startTime.compareTo(a.startTime));
      return legacyWalks;
    }

    final linkedResponse = await _supabase
        .from('walks')
        .select('*, walk_dogs(dog_id)')
        .inFilter('id', linkedWalkIds)
        .not('end_time', 'is', null);

    final walkMap = <int, Walk>{};
    for (final walk in legacyWalks) {
      if (walk.id != null) {
        walkMap[walk.id!] = walk;
      }
    }
    for (final row in (linkedResponse as List)) {
      final walk = Walk.fromJson(row);
      if (walk.id != null) {
        walkMap[walk.id!] = walk;
      }
    }

    final result = walkMap.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return result;
  }
}
