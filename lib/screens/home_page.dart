import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'robot_detail_page.dart';
import 'add_robot_instruction_screen.dart';
import 'health_showcase_screen.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
    Widget build(BuildContext context) {

      return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ParticleBg(
        particleCount: 15,
        speed: 0.6,
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.darkBgGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // ─── HEADER ───────────────────────────────
                  StaggeredFadeIn(
                    index: 0,
                    child: GlassCard(
                      glowColor: AppColors.primary,
                      glowIntensity: 0.6,
                      borderRadius: 18,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.brandGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(widget.user.photoURL ?? ''),
                              backgroundColor: AppColors.cardDark,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CyberText(
                                  'Hello, ${widget.user.displayName?.split(" ").first ?? 'User'}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Welcome back to PawMe',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await AuthService().signOut();
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const WelcomeScreen(),
                                        transitionsBuilder: (_, a, __, child) =>
                                            FadeTransition(opacity: a, child: child),
                                        transitionDuration:
                                            const Duration(milliseconds: 400),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout,
                                          color: AppColors.textHint, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ─── YOUR ROBOTS ──────────────────────────
                  StaggeredFadeIn(
                    index: 1,
                    child: CyberSectionTitle(title: 'Your Robots'),
                  ),
                  StaggeredFadeIn(
                    index: 2,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _buildRobotCard(
                            'Rex Unit 01', '85%', '92%', true),
                        _buildRobotCard(
                            'Rover Scout', '15%', '0%', false,
                            status: 'CHARGING'),
                        _buildAddRobotCard(),
                        _buildHealthShowcaseCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ─── DAILY ROUTINES ───────────────────────
                  StaggeredFadeIn(
                    index: 3,
                    child: CyberSectionTitle(
                      title: 'Daily Routines',
                      action: 'Manage All',
                      onAction: () {},
                    ),
                  ),
                  _buildRoutineItem(
                    Icons.medication_outlined,
                    AppColors.accentPink,
                    'Morning Medicine',
                    '08:00 AM',
                    true,
                  ),
                  _buildRoutineItem(
                    Icons.restaurant_outlined,
                    AppColors.accentOrange,
                    'Breakfast Kibble',
                    '08:30 AM',
                    true,
                  ),
                  _buildRoutineItem(
                    Icons.directions_walk_outlined,
                    AppColors.accentGreen,
                    'Park Walk',
                    '05:00 PM',
                    false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════ ROBOT CARD ═══════════════
  Widget _buildRobotCard(
    String name,
    String battery,
    String signal,
    bool isOnline, {
    String status = 'ONLINE',
  }) {
    final online = isOnline;
    final glowColor = online ? AppColors.accentGreen : AppColors.textHint;
    return GlassCard(
      glowColor: glowColor,
      glowIntensity: online ? 0.8 : 0.3,
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.show_chart,
                  color: online ? AppColors.accentGreen : AppColors.textHint,
                  size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              PulsingDot(
                color: online ? Colors.greenAccent : Colors.orangeAccent,
                size: 7,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: online ? AppColors.textSecondary : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatChip(
                icon: Icons.battery_charging_full,
                label: 'Battery',
                value: battery,
                accentColor: online ? AppColors.accentGreen : AppColors.textHint,
              ),
              StatChip(
                icon: Icons.wifi,
                label: 'Signal',
                value: signal,
                accentColor: online ? AppColors.accent : AppColors.textHint,
              ),
            ],
          ),
          const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => RobotDetailPage(
                                name: name,
                                battery: battery,
                                signal: signal,
                                status: status,
                              ),
                              transitionsBuilder: (_, a, __, child) =>
                                  FadeTransition(opacity: a, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: online ? AppColors.primary : AppColors.cardBorder,
                          disabledBackgroundColor: AppColors.cardBorder,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
              child: const Text(
                'Details',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════ HEALTH SHOWCASE ═══════════════
  Widget _buildHealthShowcaseCard() {
    return GlassCard(
      glowColor: AppColors.accentPink,
      glowIntensity: 0.7,
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HealthShowcaseScreen(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPink.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPink.withOpacity(0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.favorite,
                size: 28, color: AppColors.accentPink),
          ),
          const SizedBox(height: 10),
          const Text(
            'Health Showcase',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Why your dog\'s\nhealth matters',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════ ADD ROBOT CARD ═══════════════
  Widget _buildAddRobotCard() {
    return GlassCard(
      glowColor: AppColors.accent,
      glowIntensity: 0.5,
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                const AddRobotInstructionScreen(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.accent,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connect New\nRobot',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════ ROUTINE ITEM ═══════════════
  Widget _buildRoutineItem(
    IconData icon,
    Color iconBg,
    String title,
    String time,
    bool isDone,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        glowColor: isDone ? AppColors.success : AppColors.textHint,
        glowIntensity: isDone ? 0.5 : 0.2,
        borderRadius: 14,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, color: iconBg, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.success.withOpacity(0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.success : AppColors.cardBorder,
                  width: isDone ? 0 : 1.5,
                ),
                boxShadow: isDone
                    ? [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 8)]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? AppColors.success : AppColors.textHint,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
