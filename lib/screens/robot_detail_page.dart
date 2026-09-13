import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';

class RobotDetailPage extends StatelessWidget {
  final String name;
  final String battery;
  final String signal;
  final String status;

  const RobotDetailPage({
    super.key,
    required this.name,
    required this.battery,
    required this.signal,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = status == 'ONLINE';
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Robot Details',
            style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ROBOT STATUS HEADER ─────────────────
            StaggeredFadeIn(
              index: 0,
              child: GlassCard(
                glowColor: isOnline ? AppColors.accentGreen : AppColors.textHint,
                glowIntensity: isOnline ? 1.0 : 0.3,
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isOnline
                            ? const LinearGradient(
                                colors: [AppColors.accentGreen, AppColors.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isOnline
                            ? null
                            : AppColors.textHint.withOpacity(0.12),
                        boxShadow: isOnline
                            ? [BoxShadow(color: AppColors.accentGreen.withOpacity(0.3), blurRadius: 12)]
                            : null,
                      ),
                      child: const Icon(Icons.smart_toy_outlined,
                          size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CyberText(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              PulsingDot(
                                color: isOnline
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                size: 8,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: TextStyle(
                                  color: isOnline
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glassBg,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.more_vert,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            StaggeredFadeIn(
              index: 1,
              child: CyberSectionTitle(title: 'Performance'),
            ),
            const SizedBox(height: 4),
            // ─── METRICS GRID ─────────────────────────
            StaggeredFadeIn(
              index: 2,
              child: Row(
                children: [
                  Expanded(child: _metricCard('Battery', battery, Icons.battery_charging_full, AppColors.accentGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('Signal', signal, Icons.wifi, AppColors.accent)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            StaggeredFadeIn(
              index: 3,
              child: CyberSectionTitle(title: 'System'),
            ),
            const SizedBox(height: 4),
            StaggeredFadeIn(
              index: 4,
              child: _infoCard('Firmware Version', 'v1.0.0'),
            ),
            const SizedBox(height: 8),
            StaggeredFadeIn(
              index: 5,
              child: _infoCard('Last Sync', 'Just now'),
            ),
            const SizedBox(height: 8),
            StaggeredFadeIn(
              index: 6,
              child: _infoCard('Connection Type', 'Wi-Fi'),
            ),
            const SizedBox(height: 28),

            StaggeredFadeIn(
              index: 7,
              child: NeonButton(
                label: 'Run Diagnostics',
                icon: Icons.build_outlined,
                onPressed: () {},
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      glowColor: color,
      glowIntensity: 0.8,
      borderRadius: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return GlassCard(
      glowIntensity: 0.2,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
