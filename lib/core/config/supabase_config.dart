import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Supabase 프로젝트 생성 후 아래 값 입력
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}

// Supabase 클라이언트 접근용 헬퍼
final supabase = Supabase.instance.client;
