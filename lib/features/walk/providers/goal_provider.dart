import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProvider extends ChangeNotifier {
  static const _keySteps = 'pref_goal_steps';
  static const int defaultGoalSteps = 8000;

  int _goalSteps = defaultGoalSteps;

  int get goalSteps => _goalSteps;

  GoalProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _goalSteps = prefs.getInt(_keySteps) ?? defaultGoalSteps;
    notifyListeners();
  }

  Future<void> setGoalSteps(int steps) async {
    if (steps <= 0) return;
    _goalSteps = steps;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySteps, steps);
  }
}
