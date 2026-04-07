import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final headerHeight = (size.height * 0.32).clamp(220.0, 290.0);
    final titleFontSize = (size.width * 0.085).clamp(30.0, 40.0);

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: AppColors.headerBlue,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CampusTrace',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: titleFontSize,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome to CampusTrace — your centralized platform\nfor tracking campus activities, events, and records.\nPlease log in to continue.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
