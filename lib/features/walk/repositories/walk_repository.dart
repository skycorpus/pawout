import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/walk_model.dart';

class WalkRepository {
  WalkRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<int> createWalk({
    required int dogId,
    required DateTime startTime,
  }) async {
    final response = await _supabase
        .from('walks')
        .insert({
          'dog_id': dogId,
          'start_time': startTime.toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as int;
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

  Future<List<Walk>> fetchWalks(List<int> dogIds) async {
    final response = await _supabase
        .from('walks')
        .select()
        .inFilter('dog_id', dogIds)
        .not('end_time', 'is', null)
        .order('start_time', ascending: false);

    return (response as List).map((e) => Walk.fromJson(e)).toList();
  }
}
