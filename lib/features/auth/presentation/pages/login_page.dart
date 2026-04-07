import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/login_service.dart';
import '../../data/models/login_user_request.dart';
import '../widgets/google_logo_mark.dart';
import '../widgets/login_header.dart';
import '../widgets/password_field.dart';
import '../widgets/social_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final profile = await const LoginService().login(
        LoginUserRequest(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
        arguments: profile,
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onGoogleSignInPressed() async {
    if (_isSubmitting || _isGoogleSubmitting) return;

    setState(() => _isGoogleSubmitting = true);

    try {
      final profile = await const LoginService().signInWithGoogle();

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
        arguments: profile,
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign in failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
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
                  const LoginHeader(),
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
                                label: 'Email',
                                hintText: 'Example@email.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 18),
                              PasswordField(
                                label: 'Password',
                                hintText: 'at least 8 characters',
                                controller: _passwordController,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              PrimaryButton(
                                label: 'Login',
                                onPressed: _isSubmitting
                                    ? null
                                    : _onLoginPressed,
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Or',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SocialSignInButton(
                                label: 'Sign in with Google',
                                onPressed: _isGoogleSubmitting
                                    ? null
                                    : _onGoogleSignInPressed,
                                leading: const GoogleLogoMark(),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    "Don't you have an account? ",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.register),
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: AppColors.linkBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              const Center(
                                child: Text(
                                  '© 2026 Dev. Regalado & Tan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
