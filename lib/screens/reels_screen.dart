import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Reels'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.textSecondary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── CYBER GRADIENT HEADER ───────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentPink.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPink.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.movie_creation_outlined,
                                color: AppColors.accentPink, size: 44),
                          ),
                          const SizedBox(height: 10),
                          CyberText(
                            'Daily Moments',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            gradient: LinearGradient(
                              colors: [AppColors.accentPink, AppColors.primary],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Captured by your robot cameras',
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.7,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return StaggeredFadeIn(
                  index: index,
                  child: _ReelCard(
                    robotName:
                        index % 2 == 0 ? 'Rex Unit 01' : 'Rover Scout',
                    time: index % 2 == 0
                        ? 'Today · 14:30'
                        : 'Yesterday · 09:15',
                    duration: index % 2 == 0 ? '00:15' : '00:12',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelCard extends StatelessWidget {
  final String robotName;
  final String time;
  final String duration;

  const _ReelCard({
    required this.robotName,
    required this.time,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          glowColor: AppColors.accentPink,
          glowIntensity: 0.5,
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── THUMBNAIL ─────────────────────────────
          Stack(
            children: [
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentPink.withOpacity(0.12),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      size: 36,
                      color: AppColors.accentPink,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ─── INFO ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: AppColors.accentPink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        robotName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
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