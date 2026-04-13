import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/common_code_model.dart';

class CommonCodeProvider extends ChangeNotifier {
  final Map<String, List<CommonCode>> _codes = {};
  final _supabase = Supabase.instance.client;

  List<CommonCode> getGroup(String groupCode) => _codes[groupCode] ?? [];

  String getCodeName(String groupCode, String code) {
    final list = _codes[groupCode] ?? [];
    try {
      return list.firstWhere((c) => c.code == code).codeName;
    } catch (_) {
      return code; // 매핑 없으면 code 그대로 표시
    }
  }

  Future<void> fetchGroup(String groupCode) async {
    if (_codes.containsKey(groupCode)) return; // 이미 로드된 경우 스킵

    try {
      final response = await _supabase
          .from('common_codes')
          .select()
          .eq('group_code', groupCode)
          .order('sort_order');

      _codes[groupCode] =
          (response as List).map((e) => CommonCode.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }
}
