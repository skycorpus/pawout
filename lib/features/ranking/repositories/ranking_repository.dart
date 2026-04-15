import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_model.dart';

class RankingRepository {
  RankingRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<RankingEntry>> fetchDailyRankings(DateTime date) async {
    final dateKey = date.toIso8601String().substring(0, 10);
    final response = await _supabase
        .from('daily_rankings')
        .select('*, dogs(name, profile_image_url, user_id, profiles(name))')
        .eq('date', dateKey)
        .order('total_steps', ascending: false)
        .order('total_distance_km', ascending: false)
        .limit(50);

    return (response as List).map((item) {
      return RankingEntry.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRankingsForDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final fromKey = from.toIso8601String().substring(0, 10);
    final toKey = to.toIso8601String().substring(0, 10);
    final response = await _supabase
        .from('daily_rankings')
        .select('*, dogs(name, profile_image_url, user_id, profiles(name))')
        .gte('date', fromKey)
        .lte('date', toKey)
        .order('date', ascending: false)
        .limit(500);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateDogRanking({
    required int dogId,
    required DateTime date,
    required int steps,
    required double distanceKm,
  }) async {
    final dateKey = date.toIso8601String().substring(0, 10);
    final existing = await _supabase
        .from('daily_rankings')
        .select()
        .eq('dog_id', dogId)
        .eq('date', dateKey)
        .maybeSingle();

    final newSteps = (existing?['total_steps'] as int? ?? 0) + steps;
    final newDistance =
        ((existing?['total_distance_km'] as num?)?.toDouble() ?? 0.0) +
            distanceKm;

    await _supabase.from('daily_rankings').upsert(
      {
        'dog_id': dogId,
        'date': dateKey,
        'total_steps': newSteps,
        'total_distance_km': double.parse(newDistance.toStringAsFixed(2)),
      },
      onConflict: 'dog_id,date',
    );
  }
}
