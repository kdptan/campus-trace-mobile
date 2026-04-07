import 'dart:convert';

import 'package:flutter/services.dart';

final class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static Future<AppConfig> load() async {
    final jsonString = await rootBundle.loadString('env/dev.json');
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;

    return AppConfig(
      supabaseUrl: json['SUPABASE_URL'] as String? ?? '',
      supabaseAnonKey: json['SUPABASE_ANON_KEY'] as String? ?? '',
    );
  }
}
