import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';

class RegisterService {
  const RegisterService();

  SupabaseClient get _client {
    if (!AppConfig.isSupabaseConfigured) {
      throw AppException(
        'Supabase is not configured. Run with --dart-define=SUPABASE_URL=... '
        'and --dart-define=SUPABASE_ANON_KEY=...'
        '.',
      );
    }

    return Supabase.instance.client;
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();

    final authResponse = await _client.auth.signUp(
      email: trimmedEmail,
      password: password,
    );

    final userId = authResponse.user?.id;
    if (userId == null) {
      throw AppException('Sign up failed: missing user id.');
    }

    await _client.from('users').insert({
      'id': userId,
      'email': trimmedEmail,
      'firstName': trimmedFirstName.isEmpty ? null : trimmedFirstName,
      'lastName': trimmedLastName.isEmpty ? null : trimmedLastName,
      'role': null,
    });
  }
}
