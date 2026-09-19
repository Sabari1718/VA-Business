import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/models/business_entity_model.dart';
import '../../providers/business_providers.dart';

class StartBusinessWizardDialog extends ConsumerStatefulWidget {
  final int initialStep;
  const StartBusinessWizardDialog({super.key, this.initialStep = 0});

  static Future<void> show(BuildContext context, {int initialStep = 0}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StartBusinessWizardDialog(initialStep: initialStep),
    );
  }

  @override
  ConsumerState<StartBusinessWizardDialog> createState() =>
      _StartBusinessWizardDialogState();
}

class _StartBusinessWizardDialogState
    extends ConsumerState<StartBusinessWizardDialog> {
  final _brandController = TextEditingController();
  final _tradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessSetupControllerProvider.notifier).setStep(widget.initialStep);
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _tradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(businessSetupControllerProvider);
    final setupNotifier = ref.read(businessSetupControllerProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Setup Wizard',
                        style: AppTypography.headingMedium.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Step ${setupState.currentStepIndex + 1} of 3',
                        style: AppTypography.footerText.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Row(
                children: List.generate(3, (index) {
                  final isActive = index <= setupState.currentStepIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryLight : AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Content according to step
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(setupState, setupNotifier),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceBorder),
              const SizedBox(height: 12),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (setupState.currentStepIndex > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        setupNotifier.setStep(setupState.currentStepIndex - 1);
                      },
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMedium,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  if (setupState.currentStepIndex < 2)
                    ElevatedButton.icon(
                      onPressed: () {
                        setupNotifier.setStep(setupState.currentStepIndex + 1);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                      label: const Text('Continue', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: setupState.isSubmitting
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await setupNotifier.completeSetup();
                              if (success && mounted) {
                                navigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '🎉 Business "${setupState.brandName.isEmpty ? 'Your Business' : setupState.brandName}" registered successfully!',
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: setupState.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete Setup ✓',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BusinessSetupState state,
    BusinessSetupController notifier,
  ) {
    switch (state.currentStepIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1: Basic Business Info', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(
              'Enter your official brand identity and your legal trade name.',
              style: AppTypography.cardBody,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _brandController,
              onChanged: (val) => notifier.updateBrandName(val),
              decoration: InputDecoration(
                labelText: 'Official Brand Name',
                hintText: 'e.g., Nova Tech Innovations',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tradeController,
              onChanged: (val) => notifier.updateTradeName(val),
              decoration: InputDecoration(
                labelText: 'Trade / Registered Name',
                hintText: 'e.g., Nova Tech Private Limited',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Text('GST Registration Preference', style: AppTypography.cardTitle.copyWith(fontSize: 15)),
            const SizedBox(height: 8),
            ...GstPreference.values.map(
              (gst) {
                final isSelected = state.selectedGst == gst;
                return InkWell(
                  onTap: () => notifier.updateGstPreference(gst),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primaryLight : AppColors.iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(gst.label, style: AppTypography.navText),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2: Legal Entity Structure', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(
              'Select the appropriate legal registration framework for your business.',
              style: AppTypography.cardBody,
            ),
            const SizedBox(height: 16),
            ...EntityType.values.map(
              (type) {
                final isSelected = state.selectedEntityType == type;
                return InkWell(
                  onTap: () => notifier.updateEntityType(type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primaryLight : AppColors.surfaceBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.primarySubtle : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primaryLight : AppColors.iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primaryLight : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );

      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3: Legal Insights & Review', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(
              'Instant legal compliance summary tailored to your selected entity.',
              style: AppTypography.cardBody,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.step3Bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.step3BadgeBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.step3Icon),
                      const SizedBox(width: 8),
                      Text(
                        'Verified Legal Eligibility',
                        style: AppTypography.cardTitle.copyWith(color: AppColors.step3BadgeText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Structure: ${state.selectedEntityType.label}',
                    style: AppTypography.cardBody.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Tax Model: ${state.selectedGst.label}',
                    style: AppTypography.cardBody.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Compliance: Low risk, standard quarterly reporting & digital sign-off.',
                    style: AppTypography.cardBody.copyWith(color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary Details', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Brand: ${state.brandName.isEmpty ? "Not specified" : state.brandName}'),
                  Text('Trade Name: ${state.tradeName.isEmpty ? "Not specified" : state.tradeName}'),
                ],
              ),
            ),
          ],
        );
    }
  }
}
