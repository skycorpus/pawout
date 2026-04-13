import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/common_code_model.dart';

class CommonCodeRepository {
  CommonCodeRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<CommonCode>> fetchGroup(String groupCode) async {
    final response = await _supabase
        .from('common_codes')
        .select()
        .eq('group_code', groupCode)
        .order('sort_order');

    return (response as List).map((e) => CommonCode.fromJson(e)).toList();
  }
}
