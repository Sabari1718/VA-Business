import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../models/business_step_model.dart';
import '../models/business_entity_model.dart';

class BusinessRepository {
  List<BusinessStepModel> getSetupSteps() {
    return const [
      BusinessStepModel(
        stepNumber: '01',
        title: 'Basic Business Info',
        description:
            'Define your official brand or trade name and choose your GST registration preference.',
        icon: Icons.edit_note_rounded,
        badgeText: 'STEP 01',
        bgLightColor: AppColors.step1Bg,
        iconColor: AppColors.step1Icon,
        badgeBorderColor: AppColors.step1BadgeBorder,
        badgeTextColor: AppColors.step1BadgeText,
        badgeBgColor: AppColors.step1BadgeBg,
      ),
      BusinessStepModel(
        stepNumber: '02',
        title: 'Entity Structure',
        description:
            'Choose from Proprietorship, Partnership, Pvt Ltd, OPC, or LLP legal models.',
        icon: Icons.account_tree_outlined,
        badgeText: 'STEP 02',
        bgLightColor: AppColors.step2Bg,
        iconColor: AppColors.step2Icon,
        badgeBorderColor: AppColors.step2BadgeBorder,
        badgeTextColor: AppColors.step2BadgeText,
        badgeBgColor: AppColors.step2BadgeBg,
      ),
      BusinessStepModel(
        stepNumber: '03',
        title: 'Legal Insights',
        description:
            'Understand key rights, tax benefits, and compliance requirements instantly.',
        icon: Icons.verified_user_outlined,
        badgeText: 'STEP 03',
        bgLightColor: AppColors.step3Bg,
        iconColor: AppColors.step3Icon,
        badgeBorderColor: AppColors.step3BadgeBorder,
        badgeTextColor: AppColors.step3BadgeText,
        badgeBgColor: AppColors.step3BadgeBg,
      ),
    ];
  }

  final List<BusinessProfile> _sampleBusinesses = [
    BusinessProfile(
      id: '#21',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      businessType: 'Retail & Wholesale',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      registrationStatus: 'Active',
      tier: 'Startup',
      establishmentYear: '2024',
      employeeCount: '1-10 Employees',
      turnoverRange: 'Up to 20 Lakhs',
      phone: '+91 9965437236',
      email: 'contact@sabari.com',
      website: 'https://sabari.com',
      pincode: '600001',
      city: 'Chennai',
      district: 'Chennai',
      stateName: 'Tamil Nadu',
      country: 'India',
      fullAddress: 'No 12, Main Road, Industrial Estate, Adyar',
      latitude: '13.0827',
      longitude: '80.2707',
      gstNumber: '33AAAAA0000A1Z5',
      udyamNumber: 'UDYAM-TN-01-0012345',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BusinessProfile(
      id: '#22',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BusinessProfile(
      id: '#23',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BusinessProfile(
      id: '#24',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    BusinessProfile(
      id: '#25',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    BusinessProfile(
      id: '#26',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  List<BusinessProfile> getBusinesses() => List.unmodifiable(_sampleBusinesses);

  void addBusiness(BusinessProfile profile) {
    _sampleBusinesses.insert(0, profile);
  }

  void updateBusiness(BusinessProfile updated) {
    final idx = _sampleBusinesses.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _sampleBusinesses[idx] = updated;
    }
  }
}
