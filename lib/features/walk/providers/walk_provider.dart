import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

import '../models/walk_model.dart';
import '../repositories/walk_repository.dart';
import '../services/walk_metrics_service.dart';

enum StopWalkResult { saved, tooShort, error }

class WalkProvider extends ChangeNotifier {
  WalkProvider({
    WalkRepository? repository,
    WalkMetricsService? metricsService,
  })  : _repository = repository ?? WalkRepository(),
        _metricsService = metricsService ?? const WalkMetricsService();

  final WalkRepository _repository;
  final WalkMetricsService _metricsService;
  bool _isWalking = false;
  int? _currentDogId;
  List<int> _currentDogIds = [];
  int? _currentWalkId;
  DateTime? _startTime;
  int _steps = 0;
  double _distanceKm = 0.0;
  Duration _elapsed = Duration.zero;
  List<Map<String, double>> _routePoints = [];
  List<Walk> _walks = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _initialStepCount = 0;
  bool _stepCountInitialized = false;
  WalkMetricsState _metricsState = const WalkMetricsState(
    distanceKm: 0,
    routePoints: [],
    lastLatitude: null,
    lastLongitude: null,
  );
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<Position>? _posSub;
  Timer? _timer;

  bool get isWalking => _isWalking;
  int? get currentDogId => _currentDogId;
  List<int> get currentDogIds => List.unmodifiable(_currentDogIds);
  int get steps => _steps;
  double get distanceKm => _distanceKm;
  Duration get elapsed => _elapsed;
  List<Map<String, double>> get routePoints => List.unmodifiable(_routePoints);
  List<Walk> get walks => List.unmodifiable(_walks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 현재 연속 산책 일수 (오늘 포함, 하루라도 빠지면 0부터)
  int get currentStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 날짜별 산책 여부 집합
    final walkedDays = _walks
        .map((w) => DateTime(
            w.startTime.year, w.startTime.month, w.startTime.day))
        .toSet();

    int streak = 0;
    var checkDay = today;

    // 오늘 산책이 없으면 어제부터 체크
    if (!walkedDays.contains(checkDay)) {
      checkDay = today.subtract(const Duration(days: 1));
    }

    while (walkedDays.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 오늘 완료된 산책 걸음수 합계 + 현재 진행 중인 세션 걸음수
  int get todayTotalSteps {
    final now = DateTime.now();
    final completedToday = _walks
        .where((w) =>
            w.startTime.year == now.year &&
            w.startTime.month == now.month &&
            w.startTime.day == now.day)
        .fold(0, (sum, w) => sum + w.steps);
    return completedToday + (_isWalking ? _steps : 0);
  }

  void _resetActiveWalkState() {
    _isWalking = false;
    _currentDogId = null;
    _currentDogIds = [];
    _currentWalkId = null;
    _startTime = null;
    _steps = 0;
    _distanceKm = 0.0;
    _elapsed = Duration.zero;
    _routePoints = [];
    _metricsState = _metricsService.initialState();
    _initialStepCount = 0;
    _stepCountInitialized = false;
  }

  Future<bool> startWalk(List<int> dogIds) async {
    if (_isWalking) {
      return false;
    }
    if (dogIds.isEmpty) {
      _errorMessage = 'Select at least one dog.';
      notifyListeners();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permission is required.';
      notifyListeners();
      return false;
    }

    _isWalking = true;
    _currentDogId = dogIds.first;
    _currentDogIds = List.unmodifiable(dogIds);
    _startTime = DateTime.now();
    _steps = 0;
    _distanceKm = 0.0;
    _elapsed = Duration.zero;
    _routePoints = [];
    _metricsState = _metricsService.initialState();
    _initialStepCount = 0;
    _stepCountInitialized = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentWalkId = await _repository.createWalk(
        primaryDogId: dogIds.first,
        dogIds: dogIds,
        startTime: _startTime!,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _resetActiveWalkState();
      notifyListeners();
      return false;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    _stepSub = Pedometer.stepCountStream.listen(
      (event) {
        if (!_stepCountInitialized) {
          _initialStepCount = event.steps;
          _stepCountInitialized = true;
        }
        _steps = event.steps - _initialStepCount;
        notifyListeners();
      },
      onError: (_) {},
    );

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (pos) {
        _metricsState = _metricsService.appendPoint(
          current: _metricsState,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        _distanceKm = _metricsState.distanceKm;
        _routePoints = _metricsState.routePoints;
        notifyListeners();
      },
      onError: (_) {},
    );

    return true;
  }

  static const double _minDistanceKm = 0.1;
  static const int _minDurationSec = 60;

  Future<StopWalkResult> stopWalk() async {
    if (!_isWalking || _currentWalkId == null || _startTime == null) {
      return StopWalkResult.error;
    }

    _timer?.cancel();
    await _stepSub?.cancel();
    await _posSub?.cancel();

    final endTime = DateTime.now();
    final durationSec = endTime.difference(_startTime!).inSeconds;

    // 최소 기록 조건 미달 시 취소
    if (_distanceKm < _minDistanceKm || durationSec < _minDurationSec) {
      final walkId = _currentWalkId!;
      _resetActiveWalkState();
      notifyListeners();
      try {
        await _repository.cancelWalk(walkId);
      } catch (_) {}
      return StopWalkResult.tooShort;
    }

    try {
      await _repository.completeWalk(
        walkId: _currentWalkId!,
        endTime: endTime,
        distanceKm: _distanceKm,
        steps: _steps,
        routePoints: _routePoints,
      );

      _walks.insert(
        0,
        Walk(
          id: _currentWalkId,
          dogId: _currentDogId!,
          startTime: _startTime!,
          endTime: endTime,
          distanceKm: _distanceKm,
          steps: _steps,
          routePoints: List.unmodifiable(_routePoints),
        ),
      );

      _resetActiveWalkState();
      notifyListeners();
      return StopWalkResult.saved;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return StopWalkResult.error;
    }
  }

  Future<void> fetchWalks(List<int> dogIds) async {
    if (dogIds.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _walks = await _repository.fetchWalks(dogIds);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stepSub?.cancel();
    _posSub?.cancel();
    super.dispose();
  }
}
