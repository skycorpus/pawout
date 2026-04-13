import 'package:flutter/foundation.dart';

import '../models/ranking_model.dart';
import '../repositories/ranking_repository.dart';

class RankingProvider extends ChangeNotifier {
  RankingProvider({RankingRepository? repository})
      : _repository = repository ?? RankingRepository();

  final RankingRepository _repository;
  List<RankingEntry> _rankings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RankingEntry> get rankings => List.unmodifiable(_rankings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDailyRankings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rankings = await _repository.fetchDailyRankings(DateTime.now());
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDogRanking({
    required int dogId,
    required int steps,
    required double distanceKm,
  }) async {
    try {
      await _repository.updateDogRanking(
        dogId: dogId,
        date: DateTime.now(),
        steps: steps,
        distanceKm: distanceKm,
      );
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
