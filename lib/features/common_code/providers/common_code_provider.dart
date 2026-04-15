import 'package:flutter/foundation.dart';

import '../models/common_code_model.dart';
import '../repositories/common_code_repository.dart';

class CommonCodeProvider extends ChangeNotifier {
  CommonCodeProvider({CommonCodeRepository? repository})
      : _repository = repository ?? CommonCodeRepository();

  final CommonCodeRepository _repository;
  final Map<String, List<CommonCode>> _codes = {};

  List<CommonCode> getGroup(String groupCode) => _codes[groupCode] ?? [];

  String getCodeName(String groupCode, String code) {
    final list = _codes[groupCode] ?? [];
    try {
      return list.firstWhere((c) => c.code == code).codeName;
    } catch (_) {
      return code;
    }
  }

  Future<void> fetchGroup(String groupCode) async {
    if (_codes.containsKey(groupCode)) {
      return;
    }

    try {
      final result = await _repository.fetchGroup(groupCode);
      debugPrint('[CommonCode] $groupCode → ${result.length}건: ${result.map((e) => e.code).toList()}');
      _codes[groupCode] = result;
      notifyListeners();
    } catch (e) {
      debugPrint('[CommonCode] fetch 오류: $e');
    }
  }
}
