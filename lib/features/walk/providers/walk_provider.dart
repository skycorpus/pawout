import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/walk_model.dart';

class WalkProvider extends ChangeNotifier {
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
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<Position>? _posSub;
  Timer? _timer;

  final _supabase = Supabase.instance.client;

  bool get isWalking => _isWalking;
  int? get currentDogId => _currentDogId;
  int get steps => _steps;
  double get distanceKm => _distanceKm;
  Duration get elapsed => _elapsed;
  List<Walk> get walks => List.unmodifiable(_walks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> startWalk(int dogId) async {
    if (_isWalking) return false;

    // 위치 권한 확인
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _errorMessage = '위치 권한이 필요합니다. 설정에서 허용해주세요.';
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
    _lastPosition = null;
    _initialStepCount = 0;
    _stepCountInitialized = false;
    _errorMessage = null;
    notifyListeners();

    // Supabase에 산책 시작 기록
    try {
      final response = await _supabase.from('walks').insert({
        'dog_id': dogId,
        'start_time': _startTime!.toIso8601String(),
      }).select().single();
      _currentWalkId = response['id'] as int;
    } catch (e) {
      _errorMessage = e.toString();
      _isWalking = false;
      notifyListeners();
      return false;
    }

    // 타이머 (1초마다 경과시간 업데이트)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    // 걸음수 센서
    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!_stepCountInitialized) {
          _initialStepCount = event.steps;
          _stepCountInitialized = true;
        }
        _steps = event.steps - _initialStepCount;
        notifyListeners();
      },
      onError: (_) {}, // 에뮬레이터 등 센서 없는 기기 무시
    );

    // GPS 위치 추적
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 5m 이상 이동 시 업데이트
      ),
    ).listen(
      (Position pos) {
        if (_lastPosition != null) {
          final meters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );
          _distanceKm += meters / 1000;
        }
        _lastPosition = pos;
        _routePoints.add({'lat': pos.latitude, 'lng': pos.longitude});
        notifyListeners();
      },
      onError: (_) {},
    );

    return true;
  }

  Future<bool> stopWalk() async {
    if (!_isWalking || _currentWalkId == null) return false;

    _timer?.cancel();
    await _stepSub?.cancel();
    await _posSub?.cancel();

    final endTime = DateTime.now();

    try {
      await _supabase.from('walks').update({
        'end_time': endTime.toIso8601String(),
        'distance_km': double.parse(_distanceKm.toStringAsFixed(2)),
        'steps': _steps,
        'route_points': _routePoints,
      }).eq('id', _currentWalkId!);

      _walks.insert(
        0,
        Walk(
          id: _currentWalkId,
          dogId: _currentDogId!,
          startTime: _startTime!,
          endTime: endTime,
          distanceKm: _distanceKm,
          steps: _steps,
          routePoints: _routePoints,
        ),
      );

      _isWalking = false;
      _currentDogId = null;
      _currentWalkId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchWalks(List<int> dogIds) async {
    if (dogIds.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('walks')
          .select()
          .inFilter('dog_id', dogIds)
          .not('end_time', 'is', null)
          .order('start_time', ascending: false);

      _walks = (response as List).map((e) => Walk.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
