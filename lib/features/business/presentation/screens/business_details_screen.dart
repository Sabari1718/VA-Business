import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';
import 'package:va_business/core/theme/app_colors.dart';
import '../providers/business_providers.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  final dynamic businessData;
  final String businessCategory;

  const BusinessDetailsScreen({super.key, required this.businessData, this.businessCategory = 'propagator'});

  @override
  ConsumerState<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  late Map<String, dynamic> currentData;

  @override
  void initState() {
    super.initState();
    // Copy the data so we can update it locally
    currentData = Map<String, dynamic>.from(widget.businessData);
  }

  Future<void> _updateData(Map<String, dynamic> newFields) async {
    setState(() {
      currentData.addAll(newFields);
    });
    
    final id = currentData['id']?.toString();
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Business ID not found')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final repo = ref.read(businessRepositoryProvider);
      
      if (widget.businessCategory == 'partner') {
        await repo.updatePartnerBusiness(id, currentData);
        ref.invalidate(partnerBusinessProvider);
      } else if (widget.businessCategory == 'supplier') {
        await repo.updateSupplierBusiness(id, currentData);
        ref.invalidate(supplierBusinessProvider);
      } else {
        await repo.updatePropagatorBusiness(id, currentData);
        ref.invalidate(propagatorBusinessProvider);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details Updated Successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _deleteBusiness() async {
    final id = currentData['id']?.toString();
    if (id == null || id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Business', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this business? This action cannot be undone.', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      if (widget.businessCategory == 'partner') {
        await ref.read(businessRepositoryProvider).deletePartnerBusiness(id);
        ref.invalidate(partnerBusinessProvider);
      } else if (widget.businessCategory == 'supplier') {
        await ref.read(businessRepositoryProvider).deleteSupplierBusiness(id);
        ref.invalidate(supplierBusinessProvider);
      } else {
        await ref.read(businessRepositoryProvider).deletePropagatorBusiness(id);
        ref.invalidate(propagatorBusinessProvider);
      }

      if (mounted) {
        Navigator.pop(context); // close loader
        Navigator.pop(context); // go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete business: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = currentData['businessName'] ?? currentData['name'] ?? 'Unknown Business';
    final id = currentData['id']?.toString() ?? '';
    final phone = currentData['businessPhone'] ?? 'N/A';
    final email = currentData['businessEmail'] ?? 'N/A';
    final gst = currentData['gstNumber'] ?? 'N/A';
    final pan = currentData['panNumber'] ?? 'N/A';
    final accNo = currentData['currentAccountNumber'] ?? 'N/A';
    final udyam = currentData['udyamRegistrationNumber'] ?? currentData['udyamNumber'] ?? 'N/A';
    final cin = currentData['cin'] ?? currentData['cinNumber'] ?? 'N/A';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          label: Text(
            'Back to All Businesses',
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'B',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 12),
                                      const SizedBox(width: 4),
                                      Text('Active', style: GoogleFonts.poppins(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('ID: $id', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _HeaderInfoItem(icon: Icons.location_on_outlined, text: 'Address: ${currentData['country'] ?? 'India'}'),
                      _HeaderInfoItem(icon: Icons.email_outlined, text: 'Email: $email'),
                      _HeaderInfoItem(icon: Icons.phone_outlined, text: 'Phone: $phone'),
                      _HeaderInfoItem(icon: Icons.credit_card_outlined, text: 'PAN: $pan'),
                      _HeaderInfoItem(icon: Icons.receipt_long_outlined, text: 'GSTIN: $gst'),
                      _HeaderInfoItem(icon: Icons.account_balance_outlined, text: 'A/C No: $accNo'),
                      _HeaderInfoItem(icon: Icons.business_center_outlined, text: 'Udyam: $udyam'),
                      _HeaderInfoItem(icon: Icons.business_outlined, text: 'CIN: $cin'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Actions wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.businessCategory == 'partner' ? 'Partner Business' : (widget.businessCategory == 'supplier' ? 'Supplier Business' : 'My Business'),
                          style: GoogleFonts.poppins(color: const Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _ActionButton(text: 'Business Setup', icon: Icons.settings, color: Colors.green, onPressed: () {}),
                      _ActionButton(text: 'View Details', icon: Icons.visibility_outlined, color: Colors.blue, onPressed: () {}),
                      _ActionButton(text: 'Delete', icon: Icons.delete_outline, color: Colors.red, onPressed: _deleteBusiness),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Basic Details Section
            _DetailSectionWidget(
              title: '1) Basic Details',
              subtitle: 'Business Name, Email, Phone, Website, Udyam & CIN',
              icon: Icons.assignment_outlined,
              fields: [
                {'key': 'businessName', 'label': 'BUSINESS NAME', 'value': name},
                {'key': 'businessEmail', 'label': 'BUSINESS EMAIL', 'value': email},
                {'key': 'businessPhone', 'label': 'BUSINESS PHONE', 'value': phone},
                {'key': 'panNumber', 'label': 'PAN NUMBER', 'value': pan},
                {'key': 'website', 'label': 'WEBSITE', 'value': currentData['website'] ?? currentData['businessWebsite'] ?? 'N/A'},
                {'key': 'udyamNumber', 'label': 'UDYAM REGISTRATION NO', 'value': udyam},
              ],
              onSave: _updateData,
              mediaAttachments: [
                {'key': 'companyLogo', 'label': 'BUSINESS LOGO / IMAGE', 'base64': currentData['companyLogo']},
                {'key': 'panCardPhoto', 'label': 'PAN CARD DOCUMENT', 'base64': currentData['panCardPhoto']},
                {'key': 'signaturePhoto', 'label': 'SIGNATURE PHOTO', 'base64': currentData['signaturePhoto']},
              ],
            ),
            
            // GST Details Section
            _DetailSectionWidget(
              title: '2) GST Details',
              subtitle: 'GST Number & GST Certificate document preview',
              icon: Icons.receipt_long_outlined,
              fields: [
                {'key': 'gstNumber', 'label': 'GST NUMBER', 'value': gst},
              ],
              onSave: _updateData,
              mediaAttachments: [
                {'key': 'gstCertificate', 'label': 'GST CERTIFICATE DOCUMENT', 'base64': currentData['gstCertificate']},
              ],
            ),
            
            // Bank Details Section
            _DetailSectionWidget(
              title: '3) Bank Details',
              subtitle: 'Current Account Number & Verification document reference',
              icon: Icons.account_balance_outlined,
              fields: [
                {'key': 'currentAccountNumber', 'label': 'CURRENT ACCOUNT NUMBER', 'value': accNo},
                {'key': 'documentType', 'label': 'DOCUMENT TYPE', 'value': currentData['documentType'] ?? currentData['bankDocumentType'] ?? 'N/A'},
              ],
              onSave: _updateData,
              mediaAttachments: [
                {'key': 'photo', 'label': 'BANK VERIFICATION DOCUMENT', 'base64': currentData['photo']},
              ],
            ),
            
            // Address Section
            _DetailSectionWidget(
              title: '4) Business Address',
              subtitle: 'Door No, Street, Building, Landmark, Area, District, Pincode, State & Country',
              icon: Icons.location_on_outlined,
              fields: [
                {'key': 'doorNumber', 'label': 'DOOR NUMBER', 'value': currentData['doorNumber'] ?? 'N/A'},
                {'key': 'streetName', 'label': 'STREET NAME', 'value': currentData['streetName'] ?? 'N/A'},
                {'key': 'buildingName', 'label': 'BUILDING NAME', 'value': currentData['buildingName'] ?? 'N/A'},
                {'key': 'landmark', 'label': 'LANDMARK', 'value': currentData['landmark'] ?? 'N/A'},
                {'key': 'area', 'label': 'AREA', 'value': currentData['area'] ?? 'N/A'},
                {'key': 'district', 'label': 'DISTRICT', 'value': currentData['district'] ?? 'N/A'},
                {'key': 'pincode', 'label': 'PINCODE', 'value': currentData['pincode'] ?? 'N/A'},
                {'key': 'state', 'label': 'STATE', 'value': currentData['state'] ?? 'N/A'},
                {'key': 'country', 'label': 'COUNTRY', 'value': currentData['country'] ?? 'India'},
              ],
              onSave: _updateData,
            ),
            
            // Business Type Section
            _DetailSectionWidget(
              title: '5) Business Type',
              subtitle: 'Categories, Establishment Year & Employees',
              icon: Icons.category_outlined,
              fields: [
                {'key': 'yearOfEstablishment', 'label': 'YEAR OF ESTABLISHMENT', 'value': currentData['yearOfEstablishment'] ?? 'N/A'},
                {'key': 'numberOfEmployees', 'label': 'NUMBER OF EMPLOYEES', 'value': currentData['numberOfEmployees'] ?? 'N/A'},
              ],
              onSave: _updateData,
              customWidgets: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BUSINESS TYPES / CATEGORIES', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (currentData['businessType'] is List) 
                          ? (currentData['businessType'] as List).join(', ') 
                          : (currentData['businessType']?.toString() ?? 'General'),
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderInfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 32,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: color),
        label: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _DetailSectionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Map<String, dynamic>> fields;
  final List<Map<String, dynamic>>? mediaAttachments;
  final List<Widget>? customWidgets;
  final Function(Map<String, dynamic>) onSave;

  const _DetailSectionWidget({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fields,
    required this.onSave,
    this.mediaAttachments,
    this.customWidgets,
  });

  @override
  State<_DetailSectionWidget> createState() => _DetailSectionWidgetState();
}

class _DetailSectionWidgetState extends State<_DetailSectionWidget> {
  bool isEditing = false;
  Map<String, TextEditingController> controllers = {};
  Map<String, String?> currentMedia = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    controllers.clear();
    for (var field in widget.fields) {
      controllers[field['key']] = TextEditingController(
        text: field['value'] == 'N/A' ? '' : field['value'].toString()
      );
    }
    
    currentMedia.clear();
    if (widget.mediaAttachments != null) {
      for (var media in widget.mediaAttachments!) {
        currentMedia[media['key']] = media['base64'];
      }
    }
  }

  @override
  void didUpdateWidget(covariant _DetailSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isEditing) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    Map<String, dynamic> updatedData = {};
    for (var entry in controllers.entries) {
      updatedData[entry.key] = entry.value.text;
    }
    
    for (var entry in currentMedia.entries) {
      updatedData[entry.key] = entry.value;
    }
    
    widget.onSave(updatedData);
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(widget.subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              if (!isEditing)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text('Edit', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      _initControllers(); // Reset form
                    });
                  },
                  child: Text('Editing...', style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic)),
                )
            ],
          ),
          const SizedBox(height: 24),
          
          if (isEditing)
            _buildEditForm()
          else
            _buildDisplayView(),
        ],
      ),
    );
  }

  Widget _buildDisplayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            ...widget.fields.map((f) => SizedBox(
              width: MediaQuery.of(context).size.width > 600 ? 250 : MediaQuery.of(context).size.width / 2 - 40,
              child: _DetailField(label: f['label'], value: f['value'].toString()),
            )),
            if (widget.customWidgets != null)
              ...widget.customWidgets!,
          ],
        ),
        if (widget.mediaAttachments != null && widget.mediaAttachments!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: widget.mediaAttachments!.map((media) {
              return SizedBox(
                width: 250,
                child: _MediaPreviewWidget(label: media['label'], base64String: media['base64']),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: widget.fields.map((f) {
            return SizedBox(
              width: MediaQuery.of(context).size.width > 600 ? 250 : MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f['label'],
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controllers[f['key']],
                    textCapitalization: f['label'].toString().toUpperCase().contains('PAN') || f['label'].toString().toUpperCase().contains('GST')
                        ? TextCapitalization.characters
                        : TextCapitalization.none,
                    keyboardType: f['label'].toString().toUpperCase().contains('PHONE') 
                        ? TextInputType.phone 
                        : TextInputType.text,
                    inputFormatters: [
                      if (f['label'].toString().toUpperCase().contains('PAN') || f['label'].toString().toUpperCase().contains('GST'))
                         TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase())),
                      if (f['label'].toString().toUpperCase().contains('PHONE'))
                         LengthLimitingTextInputFormatter(10),
                      if (f['label'].toString().toUpperCase().contains('PHONE'))
                         FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (widget.mediaAttachments != null && widget.mediaAttachments!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: widget.mediaAttachments!.map((media) {
              final label = media['label'];
              final key = media['key'];
              final base64String = currentMedia[key];
              final hasImage = base64String != null && base64String.isNotEmpty;

              return SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? 300 : MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    if (hasImage)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue.withOpacity(0.02),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                safeBase64Decode(base64String.split(',').last),
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Image Attached', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        currentMedia[key] = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Remove',
                                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              currentMedia[key] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.withOpacity(0.5), style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 32),
                              const SizedBox(height: 8),
                              Text('Click to upload or Drag & Drop', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                              Text('Supports all image files', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                  _initControllers();
                });
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save ${widget.title.split(') ').last}', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaPreviewWidget extends StatelessWidget {
  final String label;
  final String? base64String;

  const _MediaPreviewWidget({required this.label, this.base64String});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = base64String != null && base64String!.isNotEmpty && base64String!.contains('data:image');
    Widget imageWidget = const SizedBox();
    
    if (hasImage) {
      try {
        final b64 = base64String!.split(',').last;
        imageWidget = Image.memory(safeBase64Decode(b64.split(',').last), fit: BoxFit.cover, height: 100, width: double.infinity);
      } catch (e) {
        imageWidget = Container(
          height: 100,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    } else {
      imageWidget = Container(
        height: 100,
        color: Colors.grey.shade50,
        alignment: Alignment.center,
        child: Text('No document uploaded', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38, fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: imageWidget,
              ),
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Attached Image', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              child: Stack(
                                children: [
                                  Image.memory(safeBase64Decode(base64String!.split(',').last), fit: BoxFit.contain),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility_outlined, size: 12, color: AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text('View', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool isGrey;

  const _DetailField({
    required this.label,
    required this.value,
    this.isGrey = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGrey ? Colors.black38 : Colors.black87,
            fontStyle: isGrey ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
