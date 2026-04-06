import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final headerHeight = (size.height * 0.22).clamp(150.0, 200.0);

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: AppColors.headerBlue,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Text(
        'Register',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SF Pro Rounded',
          fontSize: 44,
          height: 1.05,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
