import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/register_service.dart';
import '../widgets/google_logo_mark.dart';
import '../widgets/password_field.dart';
import '../widgets/register_header.dart';
import '../widgets/social_sign_in_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await const RegisterService().register(
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.of(context).maybePop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required.';
    if (!email.contains('@')) return 'Enter a valid email.';
    return null;
  }

  String? _validateName(String? value, {required String fieldName}) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return '$fieldName is required.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'Please re-enter your password.';
    if (confirm != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = (constraints.maxWidth * 0.07).clamp(
              20.0,
              28.0,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 24),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LabeledTextField(
                                label: 'First Name',
                                hintText: 'Enter your first name',
                                controller: _firstNameController,
                                textInputAction: TextInputAction.next,
                                validator: (value) => _validateName(
                                  value,
                                  fieldName: 'First name',
                                ),
                              ),
                              const SizedBox(height: 18),
                              LabeledTextField(
                                label: 'Last Name',
                                hintText: 'Enter your last name',
                                controller: _lastNameController,
                                textInputAction: TextInputAction.next,
                                validator: (value) => _validateName(
                                  value,
                                  fieldName: 'Last name',
                                ),
                              ),
                              const SizedBox(height: 18),
                              LabeledTextField(
                                label: 'Enter your email',
                                hintText: 'abc12@gmail.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 18),
                              PasswordField(
                                label: 'Enter your password',
                                hintText: '**************',
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 18),
                              PasswordField(
                                label: 'Re-Enter your password',
                                hintText: '**************',
                                controller: _confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 18),
                              PrimaryButton(
                                label: 'Sign Up',
                                onPressed: _isSubmitting
                                    ? null
                                    : _onSignUpPressed,
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SocialSignInButton(
                                label: 'Continue with Google',
                                onPressed: () {},
                                leading: const GoogleLogoMark(),
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
