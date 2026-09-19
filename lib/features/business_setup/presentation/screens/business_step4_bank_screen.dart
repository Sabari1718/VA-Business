import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep4BankScreen extends ConsumerStatefulWidget {
  const BusinessStep4BankScreen({super.key});

  @override
  ConsumerState<BusinessStep4BankScreen> createState() => _BusinessStep4BankScreenState();
}

class _BusinessStep4BankScreenState extends ConsumerState<BusinessStep4BankScreen> {
  late final TextEditingController _holderController;
  late final TextEditingController _bankController;
  late final TextEditingController _branchController;
  late final TextEditingController _accountController;
  late final TextEditingController _confirmAccountController;
  late final TextEditingController _ifscController;
  late final TextEditingController _addressController;

  Future<void> _pickImage(Function(String name, String path) onPicked) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image.name, image.path);
      }
    } catch (e) {
      debugPrint('Error picking cheque/passbook image: $e');
    }
  }

  Widget _buildChequePreviewImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
      );
    }
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessSetupProvider);
    _holderController = TextEditingController(text: state.accountHolderName);
    _bankController = TextEditingController(text: state.bankName);
    _branchController = TextEditingController(text: state.branchName);
    _accountController = TextEditingController(text: state.accountNumber);
    _confirmAccountController = TextEditingController(text: state.confirmAccountNumber);
    _ifscController = TextEditingController(text: state.ifscCode);
    _addressController = TextEditingController(text: state.bankAddress);
  }

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _addressController.dispose();
    super.dispose();
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Header (Step 4 active)
              BusinessSetupStepperHeader(
                currentStep: 4,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 4: Bank Account Details
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 20 : 32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
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
                    // Card Title
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_rounded, size: 17, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Step 4: Bank Account Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 44),
                      child: Text(
                        'Enter your official business bank account details and upload supporting documents.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Row 1: 1. Account Holder, 2. Bank Name, 3. Branch Name
                    if (isMobile) ...[
                      _buildHolderField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildBankNameField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildBranchField(setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildHolderField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBankNameField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBranchField(setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Row 2: 4. Account Number, 5. Confirm Account Number, 6. IFSC Code
                    if (isMobile) ...[
                      _buildAccountNumberField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildConfirmAccountNumberField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildIfscField(setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAccountNumberField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildConfirmAccountNumberField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildIfscField(setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Row 3: 7. Account Type (Radio) & 8. Account Status (Dropdown)
                    if (isMobile) ...[
                      _buildAccountTypeSelector(setupState, setupNotifier),
                      const SizedBox(height: 16),
                      _buildAccountStatusDropdown(setupState, setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAccountTypeSelector(setupState, setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildAccountStatusDropdown(setupState, setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Row 4: 9. Bank Address & 10. Supporting Document
                    if (isMobile) ...[
                      _buildBankAddressField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildSupportingDocumentBox(setupState, setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildBankAddressField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSupportingDocumentBox(setupState, setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 36),

                    // Bottom Navigation Buttons
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => navNotifier.navigateToStep3(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Step 3'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            navNotifier.navigateToStep5();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Next: Company Scale & Tier',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 12 : 13.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHolderField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('1. Account Holder Name *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _holderController,
          onChanged: (val) => setupNotifier.updateAccountHolder(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
            hintText: 'Enter account holder name',
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

  Widget _buildBankNameField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('2. Bank Name *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _bankController,
          onChanged: (val) => setupNotifier.updateBankName(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.account_balance_outlined, size: 18, color: AppColors.textMuted),
            hintText: 'Enter bank name',
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

  Widget _buildBranchField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('3. Branch Name *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _branchController,
          onChanged: (val) => setupNotifier.updateBranchName(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textMuted),
            hintText: 'Enter branch name',
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

  Widget _buildAccountNumberField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('4. Account Number *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _accountController,
          onChanged: (val) => setupNotifier.updateAccountNumber(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.textMuted),
            hintText: 'Enter account number',
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

  Widget _buildConfirmAccountNumberField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('5. Confirm Account Number *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmAccountController,
          onChanged: (val) => setupNotifier.updateConfirmAccountNumber(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.textMuted),
            hintText: 'Re-enter account number',
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

  Widget _buildIfscField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('6. IFSC Code *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ifscController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (val) => setupNotifier.updateIfscCode(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.pin_outlined, size: 18, color: AppColors.textMuted),
            hintText: 'ENTER IFSC CODE',
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
        const SizedBox(height: 4),
        const Text(
          '11-character branch IFSC code.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildAccountTypeSelector(BusinessSetupState state, BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('7. Account Type *'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: ['Savings', 'Current', 'Other'].map((type) {
              final isSelected = state.accountType == type;
              return Expanded(
                child: InkWell(
                  onTap: () => setupNotifier.updateAccountType(type),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: type,
                        groupValue: state.accountType,
                        activeColor: const Color(0xFF2563EB),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onChanged: (val) {
                          if (val != null) setupNotifier.updateAccountType(val);
                        },
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStatusDropdown(BusinessSetupState state, BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('8. Account Status'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: const ['Active', 'Inactive', 'Dormant'].contains(state.accountStatus)
                        ? state.accountStatus
                        : 'Active',
                    isExpanded: true,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'Dormant', child: Text('Dormant')),
                    ],
                    onChanged: (val) {
                      if (val != null) setupNotifier.updateAccountStatus(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankAddressField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('9. Bank Address'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _addressController,
          maxLines: 4,
          onChanged: (val) => setupNotifier.updateBankAddress(val),
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Enter bank/branch address',
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
      ],
    );
  }

  Widget _buildSupportingDocumentBox(BusinessSetupState state, BusinessSetupController setupNotifier) {
    final isUploaded = state.chequeFileName != null || (state.chequeFilePath != null && state.chequeFilePath!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('10. Supporting Document'),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 110),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickImage((name, path) {
                  setupNotifier.updateChequeFile(name, path);
                }),
                icon: const Icon(
                  Icons.upload_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                label: const Text(
                  'Upload Cancelled Cheque / Bank Passbook',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload Cancelled Cheque or Bank Passbook front page (PDF, PNG, JPG max 5MB).',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              if (isUploaded) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        state.chequeFileName ?? 'sabari.jpeg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickImage((name, path) {
                    setupNotifier.updateChequeFile(name, path);
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildChequePreviewImage(state.chequeFilePath),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
