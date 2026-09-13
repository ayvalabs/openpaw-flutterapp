import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';

class DogHealthAnalysisScreen extends StatefulWidget {
  const DogHealthAnalysisScreen({super.key});

  @override
  State<DogHealthAnalysisScreen> createState() =>
      _DogHealthAnalysisScreenState();
}

class _DogHealthAnalysisScreenState extends State<DogHealthAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final double topFactor;
  late final double leftFactor;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    final rand = math.Random();
    topFactor = 0.25 + rand.nextDouble() * 0.35;
    leftFactor = 0.2 + rand.nextDouble() * 0.45;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
        title: const Text('Dog Health Status'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ─── HEADER ───────────────────────────────
            StaggeredFadeIn(
              index: 0,
              child: GlassCard(
                glowColor: AppColors.accentPink,
                glowIntensity: 0.6,
                borderRadius: 16,
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.accentPink, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Possible itching detected',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Highlighted areas indicate where your dog may be experiencing discomfort.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ─── DOG + OVERLAY ────────────────────────
            StaggeredFadeIn(
              index: 1,
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/dog_line.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Pulsing red overlay
                    AnimBuilder(
                      listenable: _pulseAnim,
                      builder: (context, _) {
                        return Positioned(
                          top: topFactor *
                              MediaQuery.of(context).size.width *
                              0.6,
                          left: leftFactor *
                              MediaQuery.of(context).size.width *
                              0.6,
                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.error
                                      .withOpacity(0.55 * _pulseAnim.value),
                                  AppColors.error.withOpacity(0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error
                                      .withOpacity(0.3 * _pulseAnim.value),
                                  blurRadius: 20 * _pulseAnim.value,
                                  spreadRadius: 5 * _pulseAnim.value,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ─── INFO ─────────────────────────────────
            StaggeredFadeIn(
              index: 2,
              child: GlassCard(
                glowColor: AppColors.accent,
                glowIntensity: 0.3,
                borderRadius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: AppColors.accent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'This is an early indication. Consult a veterinarian if the behavior persists.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
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
    );
  }
}