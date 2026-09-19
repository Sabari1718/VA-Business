import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';

class BadgePill extends StatelessWidget {
  const BadgePill({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.step1Bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primaryBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: isMobile ? 14 : 16,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              AppConstants.badgeText,
              style: AppTypography.badgeText.copyWith(
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
