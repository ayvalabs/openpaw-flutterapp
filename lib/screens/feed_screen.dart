import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Video Feed'),
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
              icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          StaggeredFadeIn(
            index: 0,
            child: FeedVideoCard(
              robotName: 'Rex Unit 01',
              subtitle: '2 hours ago',
              duration: '00:45',
              isLive: false,
            ),
          ),
          SizedBox(height: 16),
          StaggeredFadeIn(
            index: 1,
            child: FeedVideoCard(
              robotName: 'Rover Scout',
              subtitle: 'Live',
              duration: 'LIVE',
              isLive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedVideoCard extends StatelessWidget {
  final String robotName;
  final String subtitle;
  final String duration;
  final bool isLive;

  const FeedVideoCard({
    super.key,
    required this.robotName,
    required this.subtitle,
    required this.duration,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = isLive ? AppColors.accentPink : AppColors.primary;

    return GlassCard(
      glowColor: glowColor,
      glowIntensity: isLive ? 1.0 : 0.5,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ─── VIDEO PREVIEW ────────────────────────
          Stack(
            children: [
              // Dramatic dark preview with subtle gradient
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceDark,
                      AppColors.backgroundDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: isLive
                      ? _LivePlayIcon(glowColor: glowColor)
                      : _PlayIcon(glowColor: glowColor),
                ),
              ),
              // Duration badge (bottom-right) / LIVE badge (bottom-right)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLive
                          ? AppColors.accentPink.withOpacity(0.4)
                          : AppColors.accent.withOpacity(0.3),
                    ),
                    boxShadow: [
                      ...AppColors.glow(
                        isLive ? AppColors.accentPink : AppColors.accent,
                        intensity: 0.5,
                      ),
                    ],
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: isLive ? AppColors.accentPink : AppColors.textGlow,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // LIVE badge (top-left)
              if (isLive)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentPink.withOpacity(0.4),
                      ),
                      boxShadow: [
                        ...AppColors.glow(AppColors.accentPink, intensity: 0.6),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingDot(color: AppColors.accentPink, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.accentPink,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppColors.accentPink.withOpacity(0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // ─── INFO ROW ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.accent.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        robotName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: AppColors.textGlow.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textHint),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PLAY ICON (non-live) ──────────────────────────
class _PlayIcon extends StatelessWidget {
  final Color glowColor;
  const _PlayIcon({required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassBg,
        border: Border.all(
          color: glowColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          ...AppColors.glow(glowColor, intensity: 0.8),
        ],
      ),
      child: Icon(
        Icons.play_circle_outline,
        size: 48,
        color: glowColor,
      ),
    );
  }
}

// ─── PULSING PLAY ICON (live) ──────────────────────
class _LivePlayIcon extends StatefulWidget {
  final Color glowColor;
  const _LivePlayIcon({required this.glowColor});

  @override
  State<_LivePlayIcon> createState() => _LivePlayIconState();
}

class _LivePlayIconState extends State<_LivePlayIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassBg,
              border: Border.all(
                color: widget.glowColor.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                ...AppColors.glow(widget.glowColor, intensity: 1.2),
              ],
            ),
            child: Icon(
              Icons.play_circle_outline,
              size: 48,
              color: widget.glowColor,
            ),
          ),
        );
      },
    );
  }
}
