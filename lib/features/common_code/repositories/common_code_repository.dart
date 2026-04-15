import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/common_code_model.dart';

class CommonCodeRepository {
  CommonCodeRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<CommonCode>> fetchGroup(String groupCode) async {
    debugPrint('[CommonCodeRepo] fetchGroup($groupCode) 시작');
    final response = await _supabase
        .from('common_codes')
        .select()
        .eq('group_code', groupCode)
        .order('sort_order');

    debugPrint('[CommonCodeRepo] raw response type=${response.runtimeType}, length=${response.length}');
    if (response.isNotEmpty) {
      debugPrint('[CommonCodeRepo] first row: ${response.first}');
    }

    return (response as List).map((e) => CommonCode.fromJson(e)).toList();
  }
}
