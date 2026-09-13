import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/futuristic_ui.dart';
import '../../wifi_guide_page.dart';

class PairingModeEnabledScreen extends StatelessWidget {
  const PairingModeEnabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            StaggeredFadeIn(
              index: 0,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: 40),
            StaggeredFadeIn(
              index: 1,
              child: const CyberText(
                'Your robot is now\nin pairing mode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            StaggeredFadeIn(
              index: 2,
              child: GlassCard(
                padding: EdgeInsets.all(16),
                child: Text(
                  'You can now connect your robot\nto your Wi-Fi network.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const Spacer(),
            StaggeredFadeIn(
              index: 3,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeonButton(
                    label: 'Continue',
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const WifiGuidePage(robotSSID: 'ROBOT_AP'),
                          transitionsBuilder: (_, a, __, child) =>
                              FadeTransition(opacity: a, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}