import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'robot_control_page.dart';

class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Remote Control',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── HEADER ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.4),
                  AppColors.accent.withOpacity(0.2),
                  AppColors.backgroundDark,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppColors.glow(
                      AppColors.accent,
                      intensity: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.sports_esports,
                      color: AppColors.accent, size: 56),
                ),
                const SizedBox(height: 12),
                CyberText(
                  'Select a Robot to Control',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  glowIntensity: 1.2,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose from your available robots',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                StaggeredFadeIn(
                  index: 0,
                  child: _RobotControlCard(
                    name: 'Rex Unit 01',
                    battery: '85%',
                    signal: '92%',
                    isOnline: true,
                  ),
                ),
                SizedBox(height: 16),
                StaggeredFadeIn(
                  index: 1,
                  child: _RobotControlCard(
                    name: 'Rover Scout',
                    battery: '15%',
                    signal: '0%',
                    isOnline: false,
                    status: 'CHARGING',
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

class _RobotControlCard extends StatelessWidget {
  final String name;
  final String battery;
  final String signal;
  final bool isOnline;
  final String status;

  const _RobotControlCard({
    required this.name,
    required this.battery,
    required this.signal,
    required this.isOnline,
    this.status = 'ONLINE',
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: isOnline ? AppColors.accent : AppColors.textHint,
      glowIntensity: isOnline ? 0.8 : 0.3,
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      (isOnline ? Colors.green : Colors.orange).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? Colors.greenAccent : Colors.orangeAccent)
                          .withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PulsingDot(
                      color: isOnline ? Colors.greenAccent : Colors.orangeAccent,
                      size: 7,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color:
                            isOnline ? Colors.greenAccent : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatChip(
                icon: Icons.battery_charging_full,
                label: 'Battery',
                value: battery,
                accentColor:
                    isOnline ? AppColors.accentGreen : AppColors.textHint,
              ),
              StatChip(
                icon: Icons.wifi,
                label: 'Signal',
                value: signal,
                accentColor:
                    isOnline ? AppColors.accent : AppColors.textHint,
              ),
            ],
          ),
          const SizedBox(height: 20),
          NeonButton(
            label: 'Control Robot',
            icon: Icons.sports_esports,
            onPressed: isOnline
                ? () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const RobotControlPage(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration:
                            const Duration(milliseconds: 300),
                      ),
                    );
                  }
                : null,
            color: isOnline ? AppColors.primary : AppColors.textHint,
            height: 48,
          ),
        ],
      ),
    );
  }
}
