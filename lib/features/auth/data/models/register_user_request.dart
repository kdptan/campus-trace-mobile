class RegisterUserRequest {
  const RegisterUserRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password;
}
