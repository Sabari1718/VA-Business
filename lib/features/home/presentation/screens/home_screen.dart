import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:va_business/features/business/presentation/screens/business_create_screen.dart';
import 'package:va_business/features/business/presentation/screens/platform_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'package:va_business/features/store/presentation/screens/store_create_screen.dart';
import 'package:va_business/features/store/presentation/screens/store_list_screen.dart';
import 'package:va_business/features/business/presentation/screens/business_setup_screen.dart';
import 'package:va_business/features/business/presentation/screens/business_setup_list_screen.dart';
import 'package:va_business/features/store/presentation/screens/store_setup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:va_business/features/business/presentation/providers/business_providers.dart';
import 'package:va_business/features/business/presentation/providers/platform_providers.dart';
import 'package:va_business/features/store/presentation/providers/store_providers.dart';
import 'package:va_business/features/business/presentation/screens/create_propagator_screen.dart';
import 'package:va_business/features/business/presentation/screens/create_partner_screen.dart';
import 'package:va_business/features/business/presentation/screens/create_supplier_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate Dashboard Stats
    final b1 = ref.watch(userBusinessesProvider).valueOrNull?.count ?? 0;
    final b2 = ref.watch(propagatorBusinessProvider).valueOrNull?.count ?? 0;
    final b3 = ref.watch(partnerBusinessProvider).valueOrNull?.count ?? 0;
    final b4 = ref.watch(supplierBusinessProvider).valueOrNull?.count ?? 0;
    
    final businessesCount = b1 + b2 + b3 + b4;
    final platformsCount = ref.watch(platformsProvider).valueOrNull?.count ?? 0;
    final storesCount = ref.watch(storesProvider).valueOrNull?.length ?? 0;

    int completedSteps = 0;
    if (businessesCount > 0) completedSteps++;
    if (platformsCount > 0) completedSteps++;
    if (storesCount > 0) completedSteps++;

    final totalSteps = 3;
    final completionPercentage = ((completedSteps / totalSteps) * 100).toInt();
    final stepsRemaining = totalSteps - completedSteps;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      drawer: const _AppDrawer(),
      body: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E384D), AppColors.primaryBlue, Color(0xFF8C9EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.menu_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      elevation: 8,
                      onSelected: (value) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessCreateScreen(filterCategory: value)));
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 'Propagator',
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Text('Propagator', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Partner',
                            child: Row(
                              children: [
                                const Icon(Icons.handshake_rounded, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Text('Partner Businesses', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Supplier',
                            child: Row(
                              children: [
                                const Icon(Icons.local_shipping_rounded, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Text('Supplier Businesses', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'VA BUSINESS',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Overview of your store creation, multi-channel platform integrations, and setup progress.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E384D), AppColors.primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setup Completion',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$completionPercentage%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$stepsRemaining Step(s) Left',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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
                  const SizedBox(height: 32),
                  
                  Text(
                    'Quick Stats',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1D2B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75, // Lower ratio = taller cards (fixes overflow)
                    children: [
                      _DashboardCard(
                        title: 'Connected Platforms',
                        mainValue: '$platformsCount',
                        subValue: platformsCount > 0 ? 'Active Channels' : 'No channels',
                        iconData: Icons.layers_rounded,
                        iconColor: const Color(0xFF26D38B),
                        iconBgColor: const Color(0xFFE5F9F1),
                        showCheckmark: platformsCount > 0,
                      ),
                      _DashboardCard(
                        title: 'Stores Created',
                        mainValue: '$storesCount',
                        subValue: 'Ready to build',
                        iconData: Icons.storefront_rounded,
                        iconColor: const Color(0xFFFCAE39),
                        iconBgColor: const Color(0xFFFFF7EA),
                      ),
                      _DashboardCard(
                        title: 'Total Businesses',
                        mainValue: '$businessesCount',
                        subValue: 'Registered entities',
                        iconData: Icons.domain_rounded,
                        iconColor: const Color(0xFF4C8DFB),
                        iconBgColor: const Color(0xFFEDF4FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subValue;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final bool showCheckmark;

  const _DashboardCard({
    required this.title,
    required this.mainValue,
    required this.subValue,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              if (showCheckmark)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.green),
                ),
            ],
          ),
          const Spacer(),
          Text(
            mainValue,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1D2B),
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subValue,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // User Profile Header at top of drawer
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E384D), AppColors.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'SA',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sabarii',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    Text(
                      'Business Admin',
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', isSelected: true),
                _buildDrawerItem(
                  Icons.business_outlined, 
                  'Business create',
                  onTap: () {
                    // Close drawer first
                    Navigator.pop(context);
                    // Navigate to Business Create Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusinessCreateScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.layers_outlined, 
                  'Platform',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlatformScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.storefront_outlined, 
                  'Store create',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StoreCreateScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.list_alt_outlined, 
                  'Store list',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StoreListScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.settings_outlined, 
                  'Business setup',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusinessSetupScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.format_list_bulleted_outlined, 
                  'Business setup list',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusinessSetupListScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.store_mall_directory_outlined, 
                  'Store setup',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StoreSetupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () async {
                // Logout action: Clear SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('is_logged_in');
                
                if (!context.mounted) return;
                
                // Return to Login Screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isSelected = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : Colors.black54,
            size: 22,
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? AppColors.primaryBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}
