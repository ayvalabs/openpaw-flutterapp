import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import '../services/auth_service.dart';
import '../services/theme_provider.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: CyberText(
          'Settings',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── USER CARD ─────────────────────────────
          StaggeredFadeIn(
            index: 0,
            child: GlassCard(
              borderRadius: 16,
              glowColor: AppColors.primary,
              glowIntensity: 0.6,
              child: Row(
                children: [
                  // Glowing gradient ring around avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.cardDark,
                      child: Icon(Icons.person, color: AppColors.textSecondary, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CyberText(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.accent, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ─── PREFERENCES ────────────────────────────
          _sectionHeader('PREFERENCES'),
          const SizedBox(height: 12),

          StaggeredFadeIn(
            index: 1,
            child: _settingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Receive alerts and updates',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 8),

          StaggeredFadeIn(
            index: 2,
            child: _settingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(val),
                activeColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ─── ACCOUNT ────────────────────────────────
          _sectionHeader('ACCOUNT'),
          const SizedBox(height: 12),

          StaggeredFadeIn(
            index: 3,
            child: _navTile(Icons.security, 'Privacy & Security'),
          ),
          const SizedBox(height: 8),
          StaggeredFadeIn(
            index: 4,
            child: _navTile(Icons.help_outline, 'Help & Support'),
          ),
          const SizedBox(height: 8),
          StaggeredFadeIn(
            index: 5,
            child: _navTile(Icons.info_outline, 'About'),
          ),
          const SizedBox(height: 28),

          // ─── SIGN OUT ───────────────────────────────
          StaggeredFadeIn(
            index: 6,
            child: GlassCard(
              glowColor: AppColors.error,
              glowIntensity: 0.5,
              borderRadius: 14,
              hasBorder: true,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const WelcomeScreen(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                      (_) => false,
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyberText(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  static Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return GlassCard(
      borderRadius: 14,
      glowIntensity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 24),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: trailing,
      ),
    );
  }

  static Widget _navTile(IconData icon, String title) {
    return GlassCard(
      borderRadius: 14,
      glowIntensity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 24),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: () {},
      ),
    );
  }
}
