import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessLocationStepScreen extends ConsumerStatefulWidget {
  const BusinessLocationStepScreen({super.key});

  @override
  ConsumerState<BusinessLocationStepScreen> createState() =>
      _BusinessLocationStepScreenState();
}

class _BusinessLocationStepScreenState
    extends ConsumerState<BusinessLocationStepScreen> {
  late TextEditingController _pincodeController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessSetupControllerProvider);
    _pincodeController = TextEditingController(text: state.pincode);
    _addressController = TextEditingController(text: state.fullAddress);
    _cityController = TextEditingController(text: state.city);
    _districtController = TextEditingController(text: state.district);
    _stateController = TextEditingController(text: state.stateName);
    _countryController = TextEditingController(text: state.country);
    _latController = TextEditingController(text: state.latitude);
    _lngController = TextEditingController(text: state.longitude);
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchPincodeDetails() async {
    final pincode = _pincodeController.text.trim();
    if (pincode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a valid 6-digit Indian pincode'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📡 Fetching area details from API...'),
        duration: Duration(milliseconds: 800),
      ),
    );

    final success = await ref
        .read(businessSetupControllerProvider.notifier)
        .fetchPincode(pincode);
    final updatedState = ref.read(businessSetupControllerProvider);

    setState(() {
      _cityController.text = updatedState.city;
      _districtController.text = updatedState.district;
      _stateController.text = updatedState.stateName;
      _countryController.text = updatedState.country;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Location details fetched for pincode $pincode!'
                : '📍 Location auto-populated (${updatedState.city}, ${updatedState.stateName})',
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _fetchGpsLocation() {
    setState(() {
      _latController.text = '13.0827';
      _lngController.text = '80.2707';
    });
    ref.read(businessSetupControllerProvider.notifier).updateLatitude('13.0827');
    ref.read(businessSetupControllerProvider.notifier).updateLongitude('80.2707');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 GPS Coordinates captured successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(businessSetupControllerProvider);
    final setupNotifier = ref.read(businessSetupControllerProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);
    final isMobile = ResponsiveBuilder.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  // ==========================================
                  // 1. Top 8-Step Stepper Bar (Image 4)
                  // ==========================================
                  BusinessSetupStepperHeader(
                    currentStep: 1,
                    navNotifier: navNotifier,
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // 2. Main Step 1 Card: Address & Location
                  // ==========================================
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 20 : 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x080F172A),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Step 1: Business Address & Location Details',
                                style: AppTypography.headingMedium.copyWith(
                                  fontSize: isMobile ? 16 : 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Pincode Input + Fetch Details Button
                        _buildFieldLabel('Pincode *'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _pincodeController,
                                onChanged: (val) => setupNotifier.updatePincode(val),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 600001',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _fetchPincodeDetails,
                              icon: const Icon(Icons.search, size: 16, color: Colors.white),
                              label: const Text(
                                'Fetch Details',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Enter 6-digit Indian pincode & click 'Fetch Details' to auto-populate area.",
                          style: AppTypography.footerText.copyWith(fontSize: 12),
                        ),

                        const SizedBox(height: 24),

                        // Full Address / Building / Street *
                        _buildFieldLabel('Full Address / Building / Street *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          onChanged: (val) => setupNotifier.updateFullAddress(val),
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter Door No, Building Name, Street / Road Name',
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Row: City, District, State, Country
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 700;

                            final cityField = _buildSimpleField(
                              label: 'City / Taluk *',
                              controller: _cityController,
                              hint: 'e.g. Chennai',
                              onChanged: (val) => setupNotifier.updateCity(val),
                            );

                            final districtField = _buildSimpleField(
                              label: 'District *',
                              controller: _districtController,
                              hint: 'e.g. Chennai',
                              onChanged: (val) => setupNotifier.updateDistrict(val),
                            );

                            final stateField = _buildSimpleField(
                              label: 'State *',
                              controller: _stateController,
                              hint: 'e.g. Tamil Nadu',
                              onChanged: (val) => setupNotifier.updateState(val),
                            );

                            final countryField = _buildSimpleField(
                              label: 'Country *',
                              controller: _countryController,
                              hint: 'India',
                              enabled: false,
                              onChanged: (_) {},
                            );

                            if (isNarrow) {
                              return Column(
                                children: [
                                  cityField,
                                  const SizedBox(height: 14),
                                  districtField,
                                  const SizedBox(height: 14),
                                  stateField,
                                  const SizedBox(height: 14),
                                  countryField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: cityField),
                                const SizedBox(width: 14),
                                Expanded(child: districtField),
                                const SizedBox(width: 14),
                                Expanded(child: stateField),
                                const SizedBox(width: 14),
                                Expanded(child: countryField),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // GPS Coordinates Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.step1Bg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.my_location_rounded,
                                      size: 16,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'GPS Coordinates (Latitude & Longitude)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Automatically capture exact business location coordinates via browser GPS.',
                                          style: AppTypography.footerText.copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isMobile) ...[
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _fetchGpsLocation,
                                      icon: const Icon(Icons.location_searching, size: 15, color: Colors.white),
                                      label: const Text(
                                        'Fetch Current GPS Location',
                                        style: TextStyle(color: Colors.white, fontSize: 12.5),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryLight,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (isMobile) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _fetchGpsLocation,
                                    icon: const Icon(Icons.location_searching, size: 15, color: Colors.white),
                                    label: const Text(
                                      'Fetch Current GPS Location',
                                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryLight,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSimpleField(
                                      label: 'Latitude (° N)',
                                      controller: _latController,
                                      hint: 'e.g. 13.0827',
                                      onChanged: (val) => setupNotifier.updateLatitude(val),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildSimpleField(
                                      label: 'Longitude (° E)',
                                      controller: _lngController,
                                      hint: 'e.g. 80.2707',
                                      onChanged: (val) => setupNotifier.updateLongitude(val),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Bottom Actions: Back to Setup and Next
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => navNotifier.navigateToSetupBasic(),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Back to Setup'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textMedium,
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 14 : 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: setupState.isSubmitting
                                  ? null
                                  : () async {
                                      setupNotifier.updatePincode(_pincodeController.text.trim());
                                      setupNotifier.updateFullAddress(_addressController.text.trim());
                                      setupNotifier.updateCity(_cityController.text.trim());
                                      setupNotifier.updateDistrict(_districtController.text.trim());
                                      setupNotifier.updateState(_stateController.text.trim());
                                      setupNotifier.updateCountry(_countryController.text.trim());
                                      setupNotifier.updateLatitude(_latController.text.trim());
                                      setupNotifier.updateLongitude(_lngController.text.trim());

                                      final success = await setupNotifier.submitStep1Address();
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Address details saved to API!'),
                                            backgroundColor: Color(0xFF10B981),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                      navNotifier.navigateToStep2();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 18 : 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (setupState.isSubmitting) ...[
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    setupState.isSubmitting ? 'Saving to API...' : 'Next: Contact Details',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          const DashboardFooter(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    final isRequired = text.endsWith('*');
    final label = isRequired ? text.substring(0, text.length - 1).trim() : text;

    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSimpleField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            filled: !enabled,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
