import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';

class SupabaseService {
  SupabaseService._();

  static AppConfig? _config;

  static Future<void> initialize() async {
    _config = await AppConfig.load();

    if (!_config!.isSupabaseConfigured) {
      return;
    }

    await Supabase.initialize(
      url: _config!.supabaseUrl,
      anonKey: _config!.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client {
    final config = _config;

    if (config == null || !config.isSupabaseConfigured) {
      throw AppException(
        'Supabase is not configured. Check env/dev.json for SUPABASE_URL '
        'and SUPABASE_ANON_KEY.',
      );
    }

    return Supabase.instance.client;
  }
}
