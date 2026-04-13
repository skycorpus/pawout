import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ranking_model.dart';

class RankingProvider extends ChangeNotifier {
  List<RankingEntry> _rankings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RankingEntry> get rankings => List.unmodifiable(_rankings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _supabase = Supabase.instance.client;

  // 오늘의 랭킹 조회
  Future<void> fetchDailyRankings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);

      final response = await _supabase
          .from('daily_rankings')
          .select('*, dogs(name, profile_image_url, user_id, profiles(name))')
          .eq('date', today)
          .order('total_steps', ascending: false)
          .limit(50);

      _rankings = (response as List)
          .map((e) => RankingEntry.fromJson(e))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 산책 종료 후 당일 랭킹 upsert
  Future<void> updateDogRanking({
    required int dogId,
    required int steps,
    required double distanceKm,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // 오늘 기존 기록 조회
      final existing = await _supabase
          .from('daily_rankings')
          .select()
          .eq('dog_id', dogId)
          .eq('date', today)
          .maybeSingle();

      final newSteps = (existing?['total_steps'] as int? ?? 0) + steps;
      final newDistance =
          ((existing?['total_distance_km'] as num?)?.toDouble() ?? 0.0) +
              distanceKm;

      await _supabase.from('daily_rankings').upsert(
        {
          'dog_id': dogId,
          'date': today,
          'total_steps': newSteps,
          'total_distance_km':
              double.parse(newDistance.toStringAsFixed(2)),
        },
        onConflict: 'dog_id,date',
      );
    } catch (_) {
      // 랭킹 업데이트 실패해도 산책 기록은 유지
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
