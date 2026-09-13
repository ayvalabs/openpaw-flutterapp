import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/futuristic_ui.dart';
import 'pairing_mode_enabled_screen.dart';

class PressPairingButtonScreen extends StatefulWidget {
  const PressPairingButtonScreen({super.key});

  @override
  State<PressPairingButtonScreen> createState() =>
      _PressPairingButtonScreenState();
}

class _PressPairingButtonScreenState extends State<PressPairingButtonScreen>
    with SingleTickerProviderStateMixin {
  int _seconds = 5;
  bool _done = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startTimer();
  }

  Future<void> _startTimer() async {
    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds--);
    }
    if (mounted) {
      setState(() => _done = true);
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const CyberText(
              'Press & Hold the\nPairing Button',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.all(16),
              child: Text(
                'Press and hold the pairing button on your robot for 5 seconds',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: AnimBuilder(
                              listenable: _pulseAnim,
                              builder: (context, _) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: (_done ? AppColors.accentGreen : AppColors.primary)
                              .withOpacity(0.25 * _pulseAnim.value),
                          blurRadius: 30 * _pulseAnim.value,
                          spreadRadius: 5 * _pulseAnim.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _done ? Icons.check_circle : Icons.touch_app,
                            color: _done
                                ? AppColors.accentGreen
                                : AppColors.accent,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _done ? 'Done!' : '$_seconds',
                            style: TextStyle(
                              fontSize: _done ? 28 : 48,
                              fontWeight: FontWeight.bold,
                              color: _done
                                  ? AppColors.accentGreen
                                  : AppColors.accent,
                              shadows: [
                                Shadow(
                                  color: (_done
                                          ? AppColors.accentGreen
                                          : AppColors.accent)
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                _done ? 'Pairing mode enabled' : 'Keep holding…',
                style: TextStyle(
                  color: _done ? AppColors.accentGreen : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: _done ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const Spacer(),
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeonButton(
                  label: 'Continue',
                  onPressed: _done
                      ? () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const PairingModeEnabledScreen(),
                              transitionsBuilder: (_, a, __, child) =>
                                  FadeTransition(opacity: a, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}