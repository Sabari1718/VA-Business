import 'package:flutter/material.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import 'badge_pill.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        const BadgePill(),
        SizedBox(height: isMobile ? 14 : 20),
        Text(
          AppConstants.pageTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headingLarge.copyWith(
            fontSize: isMobile ? 22 : 32,
            letterSpacing: isMobile ? -0.2 : -0.5,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Text(
            AppConstants.pageSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.subtitle.copyWith(
              fontSize: isMobile ? 13.5 : 15,
            ),
          ),
        ),
      ],
    );
  }
}
