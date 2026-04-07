import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/errors/app_exception.dart';
import 'models/register_user_request.dart';

class RegisterService {
  const RegisterService();

  static const String _defaultRole = 'ADMIN';

  SupabaseClient get _client {
    return SupabaseService.client;
  }

  Future<void> register(RegisterUserRequest request) async {
    final trimmedEmail = request.email.trim();
    final trimmedFirstName = request.firstName.trim();
    final trimmedLastName = request.lastName.trim();

    try {
      final authResponse = await _client.auth.signUp(
        email: trimmedEmail,
        password: request.password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw AppException('Sign up failed: missing user id.');
      }

      await _client.from('users').insert(<String, dynamic>{
        'id': userId,
        'email': trimmedEmail,
        'firstName': trimmedFirstName.isEmpty ? null : trimmedFirstName,
        'lastName': trimmedLastName.isEmpty ? null : trimmedLastName,
        'role': _defaultRole,
      });
    } on AuthException catch (error) {
      throw AppException(error.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Registration failed. Please try again.');
    }
  }
}
