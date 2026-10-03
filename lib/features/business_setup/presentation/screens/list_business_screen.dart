import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../data/models/business_entity_model.dart';
import '../../providers/business_providers.dart';
import '../widgets/dashboard_footer.dart';

class ListBusinessScreen extends ConsumerWidget {
  const ListBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final businesses = ref.watch(businessListProvider);
    final selectedBizId = ref.watch(selectedBusinessIdProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(businessListProvider.notifier).refreshBusinesses(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32,
          vertical: isMobile ? 20 : 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar
                _buildHeader(context, isMobile, navNotifier, ref),

                const SizedBox(height: 24),

                // 3 Stat Overview Cards
                _buildStatCardsRow(isMobile, businesses.length.toString()),

                const SizedBox(height: 24),

                // Section 01: Propagator (N)
                _buildPropagatorSection(
                  context,
                  isMobile,
                  navNotifier,
                  ref,
                  businesses,
                  selectedBizId,
                ),

                const SizedBox(height: 24),

                // Section 02: Partner Businesses (0)
                _buildPartnerSection(context, isMobile),

                const SizedBox(height: 36),

                // Footer
                const DashboardFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header with Title, Subtitle, Sync API and "+ Add More Business" button
  Widget _buildHeader(BuildContext context, bool isMobile, NavigationNotifier navNotifier, WidgetRef ref) {
    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔄 Fetching latest businesses from API...'),
                duration: Duration(milliseconds: 800),
              ),
            );
            await ref.read(businessListProvider.notifier).refreshBusinesses();
          },
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text(
            'Sync API',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primaryLight),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        _buildAddMoreButton(navNotifier),
      ],
    );

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Business at a Glance',
                style: AppTypography.headingMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All your businesses, one place.',
                style: AppTypography.subtitle.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: actions,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Business at a Glance',
                    style: AppTypography.headingMedium.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All your businesses, one place.',
                    style: AppTypography.subtitle.copyWith(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              actions,
            ],
          );
  }

  Widget _buildAddMoreButton(NavigationNotifier navNotifier) {
    return ElevatedButton.icon(
      onPressed: () {
        navNotifier.setNavItem(NavItem.startBusiness);
        navNotifier.navigateToSetupBasic();
      },
      icon: const Icon(Icons.add, size: 17, color: Colors.white),
      label: const Text(
        'Add More Business',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Row of 3 Stat/Overview Cards
  Widget _buildStatCardsRow(bool isMobile, String propagatorCount) {
    final cards = [
      _StatCardData(
        icon: Icons.store_mall_directory_rounded,
        iconBgColor: const Color(0xFF2563EB),
        value: propagatorCount,
        title: 'Propagator',
        subtitle: 'Businesses you own & operate',
      ),
      _StatCardData(
        icon: Icons.groups_rounded,
        iconBgColor: const Color(0xFFEA580C),
        value: '0',
        title: 'Partner Businesses',
        subtitle: 'Businesses you partner with',
      ),
      _StatCardData(
        icon: Icons.calendar_today_rounded,
        iconBgColor: const Color(0xFF7C3AED),
        value: '03 Apr 2026',
        title: 'Membership Since',
        subtitle: 'Your journey started',
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSingleStatCard(c),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: cards
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildSingleStatCard(c),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSingleStatCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 01: Propagator (N)
  Widget _buildPropagatorSection(
    BuildContext context,
    bool isMobile,
    NavigationNotifier navNotifier,
    WidgetRef ref,
    List<BusinessProfile> businesses,
    String selectedBizId,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '01',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Propagator (${businesses.length})',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Businesses you own and operate',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceBorder),

          // Section Content Area
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final int crossAxisCount;
                if (availableWidth >= 960) {
                  crossAxisCount = 4;
                } else if (availableWidth >= 680) {
                  crossAxisCount = 3;
                } else if (availableWidth >= 460) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                final double itemWidth = crossAxisCount == 1
                    ? availableWidth
                    : (availableWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Dynamic Business Cards
                    ...businesses.map((biz) {
                      final isSelected = biz.id == selectedBizId;
                      return SizedBox(
                        width: itemWidth,
                        child: _buildBusinessCard(
                          context: context,
                          biz: biz,
                          isSelected: isSelected,
                          onLogin: () async {
                            ref.read(selectedBusinessIdProvider.notifier).select(biz.id);
                            navNotifier.navigateToBusinessDetails(mode: BusinessDetailsMode.overview);
                            await ref.read(businessListProvider.notifier).loadBusinessOnLogin(biz.id);
                          },
                        ),
                      );
                    }),

                    // Action Card: Register New Business
                    SizedBox(
                      width: itemWidth,
                      child: _buildRegisterBusinessCard(navNotifier),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard({
    required BuildContext context,
    required BusinessProfile biz,
    required bool isSelected,
    required VoidCallback onLogin,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                : const Color(0x050F172A),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Storefront Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Business Name
          Text(
            biz.businessName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Subtitle
          const Text(
            'Proprietorship / Propagator',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // My Business text link
          const Text(
            'My Business',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterBusinessCard(NavigationNotifier navNotifier) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with + circle icon and grid icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7DD3FC), width: 1.5),
                ),
                child: const Icon(Icons.add, color: Color(0xFF0284C7), size: 20),
              ),
              const Icon(Icons.grid_view_rounded, color: Color(0xFFBAE6FD), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Register New Business',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a new proprietorship or registered business.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                navNotifier.setNavItem(NavItem.startBusiness);
                navNotifier.navigateToSetupBasic();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Business',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section 02: Partner Businesses (0)
  Widget _buildPartnerSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '02',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Partner Businesses (0)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Businesses you collaborate or partner with',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceBorder),

          // Section Content Area
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Card: Grow Your Network
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 360),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9D5FF), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row with + circle icon and network icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24), // Spacer for centering
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
                              ),
                              child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const Icon(Icons.hub_outlined, color: Color(0xFFD8B4FE), size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Grow Your Network',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add more partners and expand your business reach.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Partner discovery network coming soon!'),
                                  backgroundColor: Color(0xFF7C3AED),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF7C3AED),
                              side: const BorderSide(color: Color(0xFF7C3AED), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Find Partners',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final IconData icon;
  final Color iconBgColor;
  final String value;
  final String title;
  final String subtitle;

  _StatCardData({
    required this.icon,
    required this.iconBgColor,
    required this.value,
    required this.title,
    required this.subtitle,
  });
}
