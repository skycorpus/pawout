import 'package:flutter/foundation.dart';

import '../models/ranking_model.dart';
import '../repositories/ranking_repository.dart';

enum RankingPeriod { daily, weekly, monthly }

class RankingProvider extends ChangeNotifier {
  RankingProvider({RankingRepository? repository})
      : _repository = repository ?? RankingRepository();

  final RankingRepository _repository;

  List<RankingEntry> _rankings = [];
  bool _isLoading = false;
  String? _errorMessage;
  RankingPeriod _period = RankingPeriod.daily;
  DateTime _rangeStart = _stripTime(DateTime.now());
  DateTime _rangeEnd = _stripTime(DateTime.now());

  List<RankingEntry> get rankings => List.unmodifiable(_rankings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RankingPeriod get period => _period;
  DateTime get rangeStart => _rangeStart;
  DateTime get rangeEnd => _rangeEnd;

  int? myBestRank(Set<int> myDogIds) {
    for (final entry in _rankings) {
      if (myDogIds.contains(entry.dogId)) {
        return entry.rank;
      }
    }
    return null;
  }

  RankingEntry? myTopEntry(Set<int> myDogIds) {
    for (final entry in _rankings) {
      if (myDogIds.contains(entry.dogId)) {
        return entry;
      }
    }
    return null;
  }

  Future<void> fetchRankings([RankingPeriod? period]) async {
    if (period != null) {
      _period = period;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = _stripTime(DateTime.now());
      final range = _resolveRange(_period, now);
      _rangeStart = range.$1;
      _rangeEnd = range.$2;

      switch (_period) {
        case RankingPeriod.daily:
          _rankings = _withRanks(await _repository.fetchDailyRankings(now));
          break;
        case RankingPeriod.weekly:
        case RankingPeriod.monthly:
          _rankings = await _fetchAggregated(_rangeStart, _rangeEnd);
          break;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyRankings() => fetchRankings(RankingPeriod.daily);

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
      await fetchRankings(_period);
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<List<RankingEntry>> _fetchAggregated(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _repository.fetchRankingsForDateRange(from, to);
    final Map<int, _RankingAccumulator> grouped = {};

    for (final row in rows) {
      final dogId = row['dog_id'] as int;
      final steps = row['total_steps'] as int? ?? 0;
      final distanceKm = (row['total_distance_km'] as num?)?.toDouble() ?? 0.0;
      final dog = row['dogs'] as Map<String, dynamic>?;
      final date = DateTime.parse(row['date'] as String);

      grouped.putIfAbsent(
        dogId,
        () => _RankingAccumulator(
          id: row['id'] as int,
          dogId: dogId,
          dog: dog,
          date: date,
        ),
      );

      grouped[dogId]!.totalSteps += steps;
      grouped[dogId]!.totalDistanceKm += distanceKm;
    }

    final entries = grouped.values.map((item) => item.toEntry()).toList();
    entries.sort((a, b) {
      final stepCompare = b.totalSteps.compareTo(a.totalSteps);
      if (stepCompare != 0) {
        return stepCompare;
      }
      return b.totalDistanceKm.compareTo(a.totalDistanceKm);
    });

    return _withRanks(entries.take(50).toList());
  }

  List<RankingEntry> _withRanks(List<RankingEntry> entries) {
    return entries.asMap().entries.map((item) {
      final index = item.key;
      final entry = item.value;
      return RankingEntry(
        id: entry.id,
        dogId: entry.dogId,
        dogName: entry.dogName,
        dogImageUrl: entry.dogImageUrl,
        ownerName: entry.ownerName,
        ownerId: entry.ownerId,
        date: entry.date,
        totalSteps: entry.totalSteps,
        totalDistanceKm: entry.totalDistanceKm,
        rank: index + 1,
      );
    }).toList(growable: false);
  }

  (DateTime, DateTime) _resolveRange(RankingPeriod period, DateTime now) {
    switch (period) {
      case RankingPeriod.daily:
        return (now, now);
      case RankingPeriod.weekly:
        return (_weekStart(now), now);
      case RankingPeriod.monthly:
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  DateTime _weekStart(DateTime value) {
    final weekday = value.weekday;
    return DateTime(value.year, value.month, value.day - (weekday - 1));
  }

  static DateTime _stripTime(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _RankingAccumulator {
  _RankingAccumulator({
    required this.id,
    required this.dogId,
    required this.dog,
    required this.date,
  });

  final int id;
  final int dogId;
  final Map<String, dynamic>? dog;
  final DateTime date;

  int totalSteps = 0;
  double totalDistanceKm = 0.0;

  RankingEntry toEntry() {
    final profile = dog?['profiles'] as Map<String, dynamic>?;
    return RankingEntry(
      id: id,
      dogId: dogId,
      dogName: dog?['name'] as String? ?? 'Unknown dog',
      dogImageUrl: dog?['profile_image_url'] as String?,
      ownerName: profile?['name'] as String? ?? 'Unknown owner',
      ownerId: dog?['user_id'] as String?,
      date: date,
      totalSteps: totalSteps,
      totalDistanceKm: double.parse(totalDistanceKm.toStringAsFixed(2)),
    );
  }
}
