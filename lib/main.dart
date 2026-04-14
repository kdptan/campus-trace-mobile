// Kyle Daniel Tan

import 'package:flutter/material.dart';

import 'app/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/data/models/auth_user_profile.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(const CampusTraceApp());
}

class CampusTraceApp extends StatelessWidget {
  const CampusTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusTrace',
      theme: AppTheme.build(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.dashboard: (context) {
          final profile =
              ModalRoute.of(context)?.settings.arguments as AuthUserProfile;
          return DashboardPage(profile: profile);
        },
      },
    );
  }
}
