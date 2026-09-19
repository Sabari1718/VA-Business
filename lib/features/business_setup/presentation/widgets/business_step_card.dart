import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/models/business_step_model.dart';

class BusinessStepCard extends StatefulWidget {
  final BusinessStepModel step;
  final VoidCallback? onTap;

  const BusinessStepCard({
    super.key,
    required this.step,
    this.onTap,
  });

  @override
  State<BusinessStepCard> createState() => _BusinessStepCardState();
}

class _BusinessStepCardState extends State<BusinessStepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? step.iconColor.withValues(alpha: 0.5) : AppColors.surfaceBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? step.iconColor.withValues(alpha: 0.08)
                    : AppColors.cardShadow,
                offset: const Offset(0, 4),
                blurRadius: _isHovered ? 16 : 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon on left, Step badge on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? 38 : 44,
                    height: isMobile ? 38 : 44,
                    decoration: BoxDecoration(
                      color: step.bgLightColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      step.icon,
                      color: step.iconColor,
                      size: isMobile ? 18 : 22,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: step.badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: step.badgeBorderColor, width: 1),
                    ),
                    child: Text(
                      step.badgeText,
                      style: AppTypography.stepBadge.copyWith(
                        color: step.badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 14 : 20),
              // Title
              Text(
                step.title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: isMobile ? 15.5 : 17,
                ),
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                step.description,
                style: AppTypography.cardBody.copyWith(
                  fontSize: isMobile ? 12.5 : 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
