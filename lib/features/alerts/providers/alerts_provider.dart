import 'package:flutter/foundation.dart';

import '../models/alert_model.dart';
import '../repositories/alerts_repository.dart';

class AlertsProvider extends ChangeNotifier {
  AlertsProvider({AlertsRepository? repository})
      : _repository = repository ?? AlertsRepository();

  final AlertsRepository _repository;
  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AlertModel> get alerts => List.unmodifiable(_alerts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _alerts.length;

  Future<void> fetchAlerts({
    required List<int> myDogIds,
    required String myUserId,
  }) async {
    if (myUserId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _repository.fetchAlerts(
        myDogIds: myDogIds,
        myUserId: myUserId,
      );
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
}
