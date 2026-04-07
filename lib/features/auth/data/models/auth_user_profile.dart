import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserProfile {
  const AuthUserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  String get fullName {
    final parts = [
      firstName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty).toList(growable: false);

    return parts.isEmpty ? 'User' : parts.join(' ');
  }

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) {
    return AuthUserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  AuthUserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
  }) {
    return AuthUserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
    );
  }

  factory AuthUserProfile.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final extractedFirstName = _readNamePart(metadata, [
      'first_name',
      'given_name',
      'givenName',
      'firstName',
    ]);
    final extractedLastName = _readNamePart(metadata, [
      'last_name',
      'family_name',
      'familyName',
      'lastName',
    ]);
    final fullName = _readNamePart(metadata, ['full_name', 'name', 'fullName']);
    final nameParts = fullName.isEmpty
        ? const <String>[]
        : fullName.split(RegExp(r'\s+'));
    final firstName = extractedFirstName.isNotEmpty
        ? extractedFirstName
        : nameParts.isNotEmpty
        ? nameParts.first
        : '';
    final lastName = extractedLastName.isNotEmpty
        ? extractedLastName
        : nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';

    return AuthUserProfile(
      id: user.id,
      email: user.email ?? '',
      firstName: firstName,
      lastName: lastName,
      role: 'ADMIN',
    );
  }

  static String _readNamePart(
    Map<String, dynamic> metadata,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = metadata[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'firstName': firstName.isEmpty ? null : firstName,
      'lastName': lastName.isEmpty ? null : lastName,
      'role': role,
    };
  }
}
