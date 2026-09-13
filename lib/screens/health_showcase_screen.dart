import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'dog_health_analysis_screen.dart';

class HealthShowcaseScreen extends StatelessWidget {
  const HealthShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Health Showcase'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StaggeredFadeIn(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/dog_line.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
                          index: 1,
                          child: CyberText(
                            'Why Your Dog\'s\nHealth Matters',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            gradient: const LinearGradient(
                              colors: [AppColors.accentGreen, AppColors.accent],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
            const SizedBox(height: 16),
            StaggeredFadeIn(
                          index: 2,
                          child: GlassCard(
                            glowColor: AppColors.accentGreen,
                            glowIntensity: 0.3,
                            borderRadius: 14,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                  'A healthy dog lives longer, stays happier, and builds a stronger bond with you. '
                  'Monitoring activity, rest, and daily routines helps detect issues early and ensures '
                  'your pet gets the care it deserves.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            StaggeredFadeIn(
              index: 3,
              child: _infoCard(
                icon: Icons.monitor_heart_outlined,
                title: 'Early Health Detection',
                desc: 'Track unusual behavior patterns and catch potential health issues before they become serious.',
                color: AppColors.accentPink,
              ),
            ),
            const SizedBox(height: 12),
            StaggeredFadeIn(
              index: 4,
              child: _infoCard(
                icon: Icons.directions_run,
                title: 'Balanced Activity',
                desc: 'Ensure your dog gets the right balance of exercise and rest every day.',
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 12),
            StaggeredFadeIn(
              index: 5,
              child: _infoCard(
                icon: Icons.favorite,
                title: 'Better Quality of Life',
                desc: 'Consistent monitoring leads to a happier, safer, and healthier companion.',
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
              index: 6,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 16),
                child: NeonButton(
                  label: 'Check Your Dog\'s Health',
                  icon: Icons.favorite,
                  color: AppColors.accentPink,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const DogHealthAnalysisScreen(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoCard({
      required IconData icon,
      required String title,
      required String desc,
      required Color color,
    }) {
      return GlassCard(
        glowColor: color,
        glowIntensity: 0.4,
        borderRadius: 16,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
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