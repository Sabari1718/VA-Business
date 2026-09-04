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
  
  // Now replace the literal string '\$gstDetails' with the actual content
  if (partnerContent.contains('\$gstDetails')) {
    partnerContent = partnerContent.replaceFirst('\$gstDetails', gstDetails);
    partnerFile.writeAsStringSync(partnerContent);
    print('Fixed \$gstDetails in partner screen!');
  } else {
    print('Could not find \$gstDetails in partner screen');
  }
}
