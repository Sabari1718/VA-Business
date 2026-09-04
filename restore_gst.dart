import 'dart:io';

void main() {
  final propFile = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  final partnerFile = File('lib/features/business/presentation/screens/create_partner_screen.dart');
  
  String propContent = propFile.readAsStringSync();
  String partnerContent = partnerFile.readAsStringSync();
  
  // Extract _buildStep2GstDetails from propagator
  final gstRegex = RegExp(r'Widget _buildStep2GstDetails\(\) \{.*?(?=// ===================== STEP 3)', dotAll: true);
  final match = gstRegex.firstMatch(propContent);
  if (match == null) {
    print('Failed to find GST details in propagator');
    return;
  }
  
  String gstDetails = match.group(0)!;
  // Rename _buildStep2GstDetails to _buildStep3GstDetails
  gstDetails = gstDetails.replaceFirst('_buildStep2GstDetails', '_buildStep3GstDetails');
  
  // Change "Back to Basic Details" button's action if needed, actually previousStep is used.
  // Wait, in propagator the back button is just:
  // OutlinedButton(onPressed: _previousStep ... child: Text('← Back to Basic Details'))
  // This is correct for partner as well, because step 2 is basic details, so back to basic details is correct.
  // BUT the next step button should be "Save & Continue to Bank Details →" which it already is.
  
  // Insert it before // ===================== STEP 4 (Wait, in partner, bank details is step 4, but originally it was STEP 3 in propagator)
  // Let's see what comment is before Bank details in partner screen.
  // Let's use string replace
  if (partnerContent.contains('Widget _buildStep4BankDetails()')) {
    partnerContent = partnerContent.replaceFirst('  Widget _buildStep4BankDetails()', '''
  // ===================== STEP 3: GST DETAILS =====================
\$gstDetails
  Widget _buildStep4BankDetails()''');
  } else {
    print('Failed to find _buildStep4BankDetails');
    return;
  }
  
  partnerFile.writeAsStringSync(partnerContent);
  print('Restored _buildStep3GstDetails in partner screen');
}
