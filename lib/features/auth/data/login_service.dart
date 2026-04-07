import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import 'models/auth_user_profile.dart';
import 'models/login_user_request.dart';

class LoginService {
  const LoginService();

  static const String _googleRedirectUrl = 'campustrace://login-callback';

  SupabaseClient get _client => SupabaseService.client;

  Future<AuthUserProfile> login(LoginUserRequest request) async {
    final trimmedEmail = request.email.trim();

    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: trimmedEmail,
        password: request.password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw AppException('Login failed: missing user id.');
      }

      final userData = await _client
          .from('users')
          .select('id, email, firstName, lastName, role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) {
        throw AppException('User profile not found.');
      }

      return AuthUserProfile.fromJson(userData);
    } on AuthException catch (error) {
      throw AppException(error.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Login failed. Please try again.');
    }
  }

  Future<AuthUserProfile> signInWithGoogle() async {
    final completer = Completer<AuthUserProfile>();
    late final StreamSubscription<AuthState> subscription;

    subscription = _client.auth.onAuthStateChange.listen((data) async {
      if (data.event != AuthChangeEvent.signedIn &&
          data.event != AuthChangeEvent.initialSession) {
        return;
      }

      final user = data.session?.user;
      if (user == null || completer.isCompleted) {
        return;
      }

      try {
        final profile = await _upsertProfileFromUser(user);
        if (!completer.isCompleted) {
          completer.complete(profile);
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : _googleRedirectUrl,
      );

      return await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw AppException('Google sign in timed out. Please try again.');
        },
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Google sign in failed. Please try again.');
    } finally {
      await subscription.cancel();
    }
  }

  Future<AuthUserProfile> _upsertProfileFromUser(User user) async {
    final derivedProfile = AuthUserProfile.fromSupabaseUser(user);
    final existingProfile = await _client
        .from('users')
        .select('id, email, firstName, lastName, role')
        .eq('id', user.id)
        .maybeSingle();

    if (existingProfile != null) {
      final storedProfile = AuthUserProfile.fromJson(existingProfile);
      final mergedProfile = storedProfile.copyWith(
        email: derivedProfile.email.isNotEmpty
            ? derivedProfile.email
            : storedProfile.email,
        firstName: storedProfile.firstName.isNotEmpty
            ? storedProfile.firstName
            : derivedProfile.firstName,
        lastName: storedProfile.lastName.isNotEmpty
            ? storedProfile.lastName
            : derivedProfile.lastName,
        role: storedProfile.role.isNotEmpty ? storedProfile.role : 'ADMIN',
      );

      await _client
          .from('users')
          .upsert(mergedProfile.toJson(), onConflict: 'id');
      return mergedProfile;
    }

    await _client
        .from('users')
        .upsert(derivedProfile.toJson(), onConflict: 'id');

    return derivedProfile;
  }
}
