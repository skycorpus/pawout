import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

import '../models/walk_model.dart';
import '../repositories/walk_repository.dart';
import '../services/walk_metrics_service.dart';

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
  Position? _lastPosition;
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
  int get steps => _steps;
  double get distanceKm => _distanceKm;
  Duration get elapsed => _elapsed;
  List<Walk> get walks => List.unmodifiable(_walks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _resetActiveWalkState() {
    _isWalking = false;
    _currentDogId = null;
    _currentWalkId = null;
    _startTime = null;
    _steps = 0;
    _distanceKm = 0.0;
    _elapsed = Duration.zero;
    _routePoints = [];
    _metricsState = _metricsService.initialState();
    _lastPosition = null;
    _initialStepCount = 0;
    _stepCountInitialized = false;
  }

  Future<bool> startWalk(int dogId) async {
    if (_isWalking) {
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
    _currentDogId = dogId;
    _startTime = DateTime.now();
    _steps = 0;
    _distanceKm = 0.0;
    _elapsed = Duration.zero;
    _routePoints = [];
    _metricsState = _metricsService.initialState();
    _lastPosition = null;
    _initialStepCount = 0;
    _stepCountInitialized = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentWalkId = await _repository.createWalk(
        dogId: dogId,
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
        _lastPosition = pos;
        notifyListeners();
      },
      onError: (_) {},
    );

    return true;
  }

  Future<bool> stopWalk() async {
    if (!_isWalking || _currentWalkId == null || _startTime == null) {
      return false;
    }

    _timer?.cancel();
    await _stepSub?.cancel();
    await _posSub?.cancel();

    final endTime = DateTime.now();

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
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
