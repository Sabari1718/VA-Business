import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:va_business/app/app.dart';
import 'package:va_business/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('AuthGate routes to LoginPage when not logged in', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith((ref) => Future.value(false)),
        ],
        child: const VABusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Secure Login'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Business Setup complete flow test: Intro -> Basic Details (GST toggle) -> Location Step 1', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith((ref) => Future.value(true)),
        ],
        child: const VABusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify on Launch Dashboard
    expect(find.text('Launch & Register Your Business'), findsOneWidget);
    expect(find.text('Start Your Business Setup'), findsOneWidget);

    // 2. Click "Start Your Business Setup"
    await tester.tap(find.text('Start Your Business Setup'));
    await tester.pumpAndSettle();

    // 3. Verify Basic Business Details screen loaded (Images 1, 2, 3)
    expect(find.text('Basic Business Details'), findsOneWidget);
    expect(find.text('With GST'), findsOneWidget);
    expect(find.text('Without GST'), findsOneWidget);
    expect(find.text('Udyam Registration Number *'), findsOneWidget);
    expect(find.text('GST Number (GSTIN) *'), findsOneWidget);
    expect(find.text('Select Business Structure'), findsOneWidget);
    expect(find.text('ABOUT THIS BUSINESS TYPE'), findsOneWidget);

    // 4. Test "Without GST" toggle (Image 2)
    await tester.tap(find.text('Without GST'));
    await tester.pumpAndSettle();

    // GSTIN field must disappear when Without GST is active
    expect(find.text('GST Number (GSTIN) *'), findsNothing);
    expect(find.text('Udyam Registration Number *'), findsOneWidget);

    // Toggle back to "With GST" (Image 1)
    await tester.tap(find.text('With GST'));
    await tester.pumpAndSettle();
    expect(find.text('GST Number (GSTIN) *'), findsOneWidget);

    // 5. Click "Save & Continue" (Image 4)
    await tester.ensureVisible(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();

    // 6. Verify Step 1: Business Address & Location Details is loaded
    expect(find.text('Step 1: Business Address & Location Details'), findsOneWidget);
    expect(find.text('Pincode *'), findsOneWidget);
    expect(find.text('Fetch Details'), findsOneWidget);
    expect(find.text('Full Address / Building / Street *'), findsOneWidget);
    expect(find.text('GPS Coordinates (Latitude & Longitude)'), findsOneWidget);

    // 7. Click "Back to Setup" and verify it returns to Basic Details
    final backBtn = find.text('Back to Setup').last;
    await tester.ensureVisible(backBtn);
    await tester.pumpAndSettle();
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Basic Business Details'), findsOneWidget);
  });

  testWidgets('List Business screen UI and navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith((ref) => Future.value(true)),
        ],
        child: const VABusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Click "List Business" in Sidebar
    expect(find.text('List Business'), findsOneWidget);
    await tester.tap(find.text('List Business'));
    await tester.pumpAndSettle();

    // 2. Verify List Business ("Your Business at a Glance") Screen
    expect(find.text('Your Business at a Glance'), findsOneWidget);
    expect(find.text('All your businesses, one place.'), findsOneWidget);
    expect(find.text('Add More Business'), findsOneWidget);

    // 3. Verify Stat Cards
    expect(find.text('Propagator'), findsOneWidget);
    expect(find.text('Businesses you own & operate'), findsOneWidget);
    expect(find.text('Partner Businesses'), findsOneWidget);
    expect(find.text('Businesses you partner with'), findsOneWidget);
    expect(find.text('Membership Since'), findsOneWidget);

    // 4. Verify Sections
    expect(find.text('01'), findsOneWidget);
    expect(find.text('Propagator (0)'), findsOneWidget);
    expect(find.text('No registered proprietorship/propagator businesses found.'), findsOneWidget);
    expect(find.text('Register New Business'), findsOneWidget);
    expect(find.text('Create Business'), findsOneWidget);

    expect(find.text('02'), findsOneWidget);
    expect(find.text('Partner Businesses (0)'), findsOneWidget);
    expect(find.text('Grow Your Network'), findsOneWidget);
    expect(find.text('Find Partners'), findsOneWidget);

    // 5. Click "Create Business" button -> redirects to Basic Business Details
    await tester.ensureVisible(find.text('Create Business'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Business'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Business Details'), findsOneWidget);
  });

  testWidgets('Business Setup complete multi-step flow test: Step 1 -> Step 2 -> Step 3 (Upload preview) -> Step 4 -> Step 5 (Tier selection)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith((ref) => Future.value(true)),
        ],
        child: const VABusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Go to Basic Details
    await tester.tap(find.text('Start Your Business Setup'));
    await tester.pumpAndSettle();

    // 2. Go to Step 1 Location
    await tester.ensureVisible(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1: Business Address & Location Details'), findsOneWidget);

    // 3. Go to Step 2: Contact & Branding (Photo 1)
    await tester.ensureVisible(find.text('Next: Contact Details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Contact Details'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2: Company Contact & Brand Identity'), findsOneWidget);
    expect(find.text('Upload Main Logo'), findsOneWidget);
    expect(find.text('Upload App Icon'), findsOneWidget);

    // 4. Go to Step 3: Legal Document Certificates & Location Photo (Photo 2 & 3)
    await tester.ensureVisible(find.text('Next: Upload Documents'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Upload Documents'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3: Legal Document Certificates & Location Photo'), findsOneWidget);
    expect(find.text('Upload Udyam PDF/Img'), findsOneWidget);

    // Test Photo 3 feature: Click Udyam upload card to toggle uploaded preview
    await tester.tap(find.text('Upload Udyam PDF/Img'));
    await tester.pumpAndSettle();

    expect(find.text('File Uploaded'), findsOneWidget);
    expect(find.text('Buy Land India Log...'), findsOneWidget);

    // 5. Go to Step 4: Bank Account Details (Photo 4)
    await tester.ensureVisible(find.text('Next: Bank Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Bank Account'));
    await tester.pumpAndSettle();

    expect(find.text('Step 4: Bank Account Details'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Upload Cancelled Cheque / Bank Passbook'), findsOneWidget);

    // 6. Go to Step 5: Company Scale & Tier Selection (Photo 5)
    await tester.ensureVisible(find.text('Next: Company Scale & Tier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Company Scale & Tier'));
    await tester.pumpAndSettle();

    expect(find.text('Step 5: Company Scale & Tier Selection'), findsOneWidget);
    expect(find.text('STARTUP'), findsOneWidget);
    expect(find.text('★ Recommended'), findsOneWidget);
    expect(find.text('STANDARD'), findsOneWidget);
    expect(find.text('CORPORATE'), findsOneWidget);

    // Test tier card selection
    await tester.tap(find.text('STANDARD'));
    await tester.pumpAndSettle();

    // Test Back navigation: Step 5 -> Step 4 -> Step 3
    await tester.ensureVisible(find.text('Back to Step 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Step 4'));
    await tester.pumpAndSettle();
    expect(find.text('Step 4: Bank Account Details'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to Step 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Step 3'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3: Legal Document Certificates & Location Photo'), findsOneWidget);
  });

  testWidgets('Mobile screen (360x800) zero-overflow test for Steps 1 through 5', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith((ref) => Future.value(true)),
        ],
        child: const VABusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Intro -> Basic Details
    await tester.ensureVisible(find.text('Start Your Business Setup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Your Business Setup'));
    await tester.pumpAndSettle();

    // Basic Details -> Step 1
    await tester.ensureVisible(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1: Business Address & Location Details'), findsOneWidget);

    // Step 1 -> Step 2
    await tester.ensureVisible(find.text('Next: Contact Details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Contact Details'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2: Company Contact & Brand Identity'), findsOneWidget);

    // Step 2 -> Step 3
    await tester.ensureVisible(find.text('Next: Upload Documents'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Upload Documents'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3: Legal Document Certificates & Location Photo'), findsOneWidget);

    // Step 3 -> Step 4
    await tester.ensureVisible(find.text('Next: Bank Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Bank Account'));
    await tester.pumpAndSettle();
    expect(find.text('Step 4: Bank Account Details'), findsOneWidget);

    // Step 4 -> Step 5
    await tester.ensureVisible(find.text('Next: Company Scale & Tier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Company Scale & Tier'));
    await tester.pumpAndSettle();
    expect(find.text('Step 5: Company Scale & Tier Selection'), findsOneWidget);
  });
}
