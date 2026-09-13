import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'home_network_connect_page.dart';

class RobotRebootPage extends StatefulWidget {
  const RobotRebootPage({super.key});

  @override
  State<RobotRebootPage> createState() => _RobotRebootPageState();
}

class _RobotRebootPageState extends State<RobotRebootPage>
    with SingleTickerProviderStateMixin {
  int _secondsRemaining = 20;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        _navigateToFinalStep();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _navigateToFinalStep() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeNetworkConnectPage(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimBuilder(
                listenable: _pulseAnim,
              builder: (context, _) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.08 * _pulseAnim.value),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.15 * _pulseAnim.value),
                        blurRadius: 20 * _pulseAnim.value,
                        spreadRadius: 4 * _pulseAnim.value,
                      ),
                    ],
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const CyberText(
                          'Robot Rebooting...',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
            const SizedBox(height: 16),
            GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                "Please wait $_secondsRemaining seconds while the robot\nconnects to your home network.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_secondsRemaining',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}