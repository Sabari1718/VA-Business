import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/business_entity_model.dart';
import '../../providers/business_providers.dart';
import '../widgets/dashboard_footer.dart';

class CategoryConfigItem {
  final String id;
  final String businessId;
  final String sectorTitle;
  final String sector;
  final String subSector;
  final DateTime createdAt;

  const CategoryConfigItem({
    required this.id,
    required this.businessId,
    required this.sectorTitle,
    required this.sector,
    required this.subSector,
    required this.createdAt,
  });
}

class BusinessCategoryMappingScreen extends ConsumerStatefulWidget {
  const BusinessCategoryMappingScreen({super.key});

  @override
  ConsumerState<BusinessCategoryMappingScreen> createState() =>
      _BusinessCategoryMappingScreenState();
}

class _BusinessCategoryMappingScreenState
    extends ConsumerState<BusinessCategoryMappingScreen> {
  final List<CategoryConfigItem> _configurations = [];

  void _showAddConfigDialog(BuildContext context, BusinessProfile activeBiz) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return _AddCategoryConfigurationDialog(
          activeBiz: activeBiz,
          onSave: (sectorTitle, sector, subSector) {
            setState(() {
              _configurations.add(
                CategoryConfigItem(
                  id: 'cfg-${DateTime.now().millisecondsSinceEpoch}',
                  businessId: activeBiz.id,
                  sectorTitle: sectorTitle,
                  sector: sector,
                  subSector: subSector,
                  createdAt: DateTime.now(),
                ),
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Configuration saved successfully for ${activeBiz.businessName}!',
                ),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final activeBiz = ref.watch(activeBusinessProvider);
    final businesses = ref.watch(businessListProvider);

    final bizConfigs =
        _configurations.where((c) => c.businessId == activeBiz.id).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 28,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              if (isMobile) ...[
                _buildTitleWithBadge(activeBiz),
                const SizedBox(height: 6),
                const Text(
                  'Manage configured sectors, sub-sectors, primary categories, sub-categories, and brand mappings for this specific business.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSwitchDropdown(businesses, activeBiz),
                    _buildAddConfigButton(context, activeBiz),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleWithBadge(activeBiz),
                          const SizedBox(height: 6),
                          const Text(
                            'Manage configured sectors, sub-sectors, primary categories, sub-categories, and brand mappings for this specific business.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        _buildSwitchDropdown(businesses, activeBiz),
                        const SizedBox(width: 10),
                        _buildAddConfigButton(context, activeBiz),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Content Area: Either Empty State (Photo 1) or Configured Items
              if (bizConfigs.isEmpty)
                _buildEmptyStateCard(isMobile, activeBiz)
              else
                _buildConfigurationsList(bizConfigs, activeBiz),

              const SizedBox(height: 36),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(bool isMobile, BusinessProfile activeBiz) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 48 : 72,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Categories or Brand Mappings Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'There are currently no active category or brand configurations assigned to ${activeBiz.businessName} (ID: ${activeBiz.id}).',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddConfigDialog(context, activeBiz),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text(
              'Add First Configuration',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationsList(
    List<CategoryConfigItem> configs,
    BusinessProfile activeBiz,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configured Mappings (${configs.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddConfigDialog(context, activeBiz),
                  icon: const Icon(Icons.add, size: 15, color: Colors.white),
                  label: const Text(
                    'Add More',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final cfg = configs[index];
              return ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Color(0xFF2563EB), size: 20),
                ),
                title: Text(
                  cfg.sectorTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text(
                  'Sector: ${cfg.sector}  •  Sub-Sector: ${cfg.subSector}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  onPressed: () {
                    setState(() {
                      _configurations.removeWhere((c) => c.id == cfg.id);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWithBadge(BusinessProfile activeBiz) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.hub_outlined, color: Color(0xFF2563EB), size: 20),
        const SizedBox(width: 8),
        const Text(
          'Propagator Categories & Brand Mapping',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Text(
            activeBiz.businessName,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchDropdown(List<BusinessProfile> businesses, BusinessProfile activeBiz) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: businesses.any((b) => b.id == activeBiz.id) ? activeBiz.id : businesses.first.id,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          items: businesses.map((b) {
            return DropdownMenuItem<String>(
              value: b.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Switch: ${b.businessName} (ID: ${b.id})',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(selectedBusinessIdProvider.notifier).select(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddConfigButton(BuildContext context, BusinessProfile activeBiz) {
    return ElevatedButton.icon(
      onPressed: () => _showAddConfigDialog(context, activeBiz),
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text(
        'Add Configuration',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }
}

// =========================================================================
// PHOTO 2: Add Category & Brand Configuration Dialog
// =========================================================================
class _AddCategoryConfigurationDialog extends StatefulWidget {
  final BusinessProfile activeBiz;
  final Function(String sectorTitle, String sector, String subSector) onSave;

  const _AddCategoryConfigurationDialog({
    required this.activeBiz,
    required this.onSave,
  });

  @override
  State<_AddCategoryConfigurationDialog> createState() =>
      _AddCategoryConfigurationDialogState();
}

class _AddCategoryConfigurationDialogState
    extends State<_AddCategoryConfigurationDialog> {
  String _selectedSectorTitle = '-- Select Sector Title --';
  String _selectedSector = '-- Select Sector --';
  String _selectedSubSector = '-- Select Sub Sector --';

  static const List<String> _sectorTitleOptions = [
    '-- Select Sector Title --',
    'Retail & Wholesale Trade',
    'Manufacturing & Production',
    'Services & Solutions',
    'Technology & Digital Commerce',
    'Agriculture & Food Processing',
  ];

  static const List<String> _sectorOptions = [
    '-- Select Sector --',
    'Retail Trade',
    'Wholesale Trade',
    'Consumer Goods',
    'Textiles & Apparel',
    'Food & Beverages',
    'Electronics & Appliances',
    'Industrial Supplies',
  ];

  static const List<String> _subSectorOptions = [
    '-- Select Sub Sector --',
    'Grocery & Supermarket',
    'Apparel & Clothing',
    'Electronics & Gadgets',
    'Footwear & Accessories',
    'Hardware & Electricals',
    'Stationery & Office Supplies',
    'Beauty & Personal Care',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header (Photo 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: const Color(0xFF2563EB),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Category & Brand Configuration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'For: ${widget.activeBiz.businessName} (ID: ${widget.activeBiz.id})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Dialog Content: 3 Dropdowns (Photo 2)
            Container(
              color: Colors.white,
              constraints: const BoxConstraints(minHeight: 280),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    _buildDropdownField(
                      label: 'Sector Title *',
                      value: _selectedSectorTitle,
                      items: _sectorTitleOptions,
                      onChanged: (v) => setState(() => _selectedSectorTitle = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Sector *',
                      value: _selectedSector,
                      items: _sectorOptions,
                      onChanged: (v) => setState(() => _selectedSector = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Sub-Sector *',
                      value: _selectedSubSector,
                      items: _subSectorOptions,
                      onChanged: (v) => setState(() => _selectedSubSector = v!),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Sector Title *',
                            value: _selectedSectorTitle,
                            items: _sectorTitleOptions,
                            onChanged: (v) => setState(() => _selectedSectorTitle = v!),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Sector *',
                            value: _selectedSector,
                            items: _sectorOptions,
                            onChanged: (v) => setState(() => _selectedSector = v!),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Sub-Sector *',
                            value: _selectedSubSector,
                            items: _subSectorOptions,
                            onChanged: (v) => setState(() => _selectedSubSector = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Footer with Cancel and Save Configuration (Photo 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onSave(
                        _selectedSectorTitle == '-- Select Sector Title --'
                            ? 'Retail & Wholesale Trade'
                            : _selectedSectorTitle,
                        _selectedSector == '-- Select Sector --'
                            ? 'Retail Trade'
                            : _selectedSector,
                        _selectedSubSector == '-- Select Sub Sector --'
                            ? 'Grocery & Supermarket'
                            : _selectedSubSector,
                      );
                    },
                    icon: const Icon(Icons.check, size: 16, color: Colors.white),
                    label: const Text(
                      'Save Configuration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
              items: items.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
