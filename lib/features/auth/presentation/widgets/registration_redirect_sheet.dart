import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationRedirectSheet extends StatelessWidget {
  final String? inputIdentifier;

  const RegistrationRedirectSheet({
    super.key,
    this.inputIdentifier,
  });

  static const String webUrl = 'https://business-setup.jobes24x7.com';
  static const String playStorePackage = 'com.sva.businessuser';
  static const String playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=com.sva.businessuser';

  Future<void> _openWeb(BuildContext context) async {
    final Uri uri = Uri.parse(webUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open web link.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening browser: $e")),
        );
      }
    }
  }

  Future<void> _openPlayStore(BuildContext context) async {
    final Uri marketUri = Uri.parse('market://details?id=$playStorePackage');
    final Uri webFallbackUri = Uri.parse(playStoreWebUrl);

    try {
      // First try opening directly in Play Store app
      final launchedMarket = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launchedMarket) {
        // Fallback to browser Play Store link
        await launchUrl(
          webFallbackUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      try {
        await launchUrl(
          webFallbackUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open Play Store: $e")),
          );
        }
      }
    }
  }

  static Future<void> show(BuildContext context, {String? identifier}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegistrationRedirectSheet(inputIdentifier: identifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Icon and Close Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Not Registered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Action Required to Continue',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Explanatory Message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                inputIdentifier != null && inputIdentifier!.isNotEmpty
                    ? 'The entered number/email "$inputIdentifier" is not yet registered. To access VA Business, please register your account first.'
                    : 'You do not have an active account yet. To access VA Business, please complete your registration first.',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Option 1: Web Portal (FIRST)
            _buildOptionCard(
              context: context,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF2563EB),
              gradientColors: [
                const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                const Color(0xFF2563EB).withValues(alpha: 0.12),
              ],
              borderColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
              badgeText: "RECOMMENDED",
              badgeColor: const Color(0xFF2563EB),
              title: "1. Register on Web Portal",
              subtitle: "business-setup.jobes24x7.com",
              actionText: "Open Web",
              onTap: () => _openWeb(context),
            ),

            const SizedBox(height: 14),

            // Option 2: Mobile App (SECOND)
            _buildOptionCard(
              context: context,
              icon: Icons.install_mobile_rounded,
              iconColor: const Color(0xFF4F46E5),
              gradientColors: [
                const Color(0xFF4338CA).withValues(alpha: 0.25),
                const Color(0xFF6366F1).withValues(alpha: 0.12),
              ],
              borderColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
              badgeText: "PLAY STORE",
              badgeColor: const Color(0xFF6366F1),
              title: "2. Download SVA Business User",
              subtitle: "Get the main app on Google Play Store",
              actionText: "Download",
              onTap: () => _openPlayStore(context),
            ),

            const SizedBox(height: 20),

            // Helper text
            Center(
              child: Text(
                "Already registered? Re-enter credentials to log in.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withValues(alpha: 0.15),
        highlightColor: iconColor.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: iconColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: iconColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
