import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════
// FUTURISTIC UI COMPONENTS — v2.0
// ═══════════════════════════════════════════════════════════════

/// ─── ANIMATED PARTICLE BACKGROUND ──────────────────────────
class ParticleBg extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final List<Color> colors;
  final double speed;

  const ParticleBg({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.colors = const [AppColors.primary, AppColors.accent, AppColors.accentPink],
    this.speed = 1.0,
  });

  @override
  State<ParticleBg> createState() => _ParticleBgState();
}

class _ParticleBgState extends State<ParticleBg> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _particles = List.generate(widget.particleCount, (i) => _Particle(
      size: 2 + math.Random().nextDouble() * 5,
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      dx: (math.Random().nextDouble() - 0.5) * 0.001 * widget.speed,
      dy: (math.Random().nextDouble() - 0.5) * 0.001 * widget.speed,
      color: widget.colors[i % widget.colors.length].withOpacity(0.2 + math.Random().nextDouble() * 0.4),
      opacity: 0.2 + math.Random().nextDouble() * 0.5,
    ));
    _controller.addListener(() {
      setState(() {
        for (final p in _particles) {
          p.x += p.dx;
          p.y += p.dy;
          if (p.x > 1 || p.x < 0) p.dx = -p.dx;
          if (p.y > 1 || p.y < 0) p.dy = -p.dy;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(_particles),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double size, x, y, dx, dy, opacity;
  Color color;
  _Particle({required this.size, required this.x, required this.y, required this.dx, required this.dy, required this.color, required this.opacity});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
    // Draw connecting lines between nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = (particles[i].x - particles[j].x) * size.width;
        final dy = (particles[i].y - particles[j].y) * size.height;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 100) {
          final opacity = (1 - dist / 100) * 0.15;
          canvas.drawLine(
            Offset(particles[i].x * size.width, particles[i].y * size.height),
            Offset(particles[j].x * size.width, particles[j].y * size.height),
            Paint()
              ..color = AppColors.primary.withOpacity(opacity)
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

/// ─── GLASSMORPHISM CONTAINER ────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final double blur;
  final bool hasBorder;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.blur = 20,
    this.hasBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? AppColors.primary;
    final bgColor = AppColors.cardDark.withOpacity(0.6);
    final borderColor = AppColors.cardBorder.withOpacity(0.4);

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(color: borderColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10 * glowIntensity),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.05 * glowIntensity),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: color.withOpacity(0.08),
          highlightColor: color.withOpacity(0.04),
          child: card,
        ),
      );
    }
    return card;
  }
}

/// ─── NEON CONTAINER (original, enhanced) ─────────────────────
class NeonContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final bool hasBorder;

  const NeonContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.glowColor,
    this.glowIntensity = 1.0,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? AppColors.primary;
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(color: AppColors.cardBorder)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12 * glowIntensity),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.06 * glowIntensity),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ─── NEON BUTTON (enhanced) ─────────────────────────────────
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double height;
  final double? width;
  final bool isLoading;
  final double borderRadius;
  final TextStyle? textStyle;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.height = 52,
    this.width,
    this.isLoading = false,
    this.borderRadius = 12,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: bgColor.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: textStyle ?? const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// ─── GRADIENT TEXT WITH CYBER GLOW ──────────────────────────
class CyberText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;
  final double glowIntensity;

  const CyberText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? const LinearGradient(
      colors: [AppColors.primary, AppColors.accent],
    );
    return ShaderMask(
      shaderCallback: (bounds) => g.createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.white,
        ),
        textAlign: textAlign,
      ),
    );
  }
}

/// ─── NEON TEXT (enhanced) ───────────────────────────────────
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final TextAlign? textAlign;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? AppColors.accent;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [color, color.withOpacity(0.8)],
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// ─── PULSING DOT (enhanced) ─────────────────────────────────
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool animate;

  const PulsingDot({
    super.key,
    this.color = Colors.greenAccent,
    this.size = 10,
    this.animate = true,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    return AnimBuilder(
      listenable: _animation,
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6 * _animation.value),
                blurRadius: 6 + (1 - _animation.value) * 4,
                spreadRadius: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─── ANIMATED SCAN LINE ─────────────────────────────────────
class ScanLineEffect extends StatefulWidget {
  final double height;
  final Color color;

  const ScanLineEffect({
    super.key,
    this.height = 200,
    this.color = AppColors.accent,
  });

  @override
  State<ScanLineEffect> createState() => _ScanLineEffectState();
}

class _ScanLineEffectState extends State<ScanLineEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimBuilder(
      listenable: _animation,
      builder: (context, _) {
        return Stack(
          children: [
            Container(height: widget.height),
            Positioned(
              top: _animation.value * widget.height,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      widget.color.withOpacity(0.8),
                      widget.color,
                      widget.color.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ─── SHIMMER LOADING ────────────────────────────────────────
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimBuilder(
      listenable: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _animation.value, 0),
              end: Alignment(1 + _animation.value, 0),
              colors: [
                AppColors.cardDark,
                AppColors.cardBorder.withOpacity(0.6),
                AppColors.cardDark,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ─── STAGGERED ENTRANCE ANIMATION ───────────────────────────
class StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;

  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final delay = widget.index * 80;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}

/// ─── SCALE ENTRANCE ANIMATION ───────────────────────────────
class ScaleFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;

  const ScaleFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final delay = widget.index * 100;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.child,
      ),
    );
  }
}

/// ─── GLOWING PROGRESS BAR ───────────────────────────────────
class GlowingProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const GlowingProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.cardBorder,
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: [c.withOpacity(0.7), c],
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── CYBER SECTION TITLE ────────────────────────────────────
class CyberSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const CyberSectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ─── STAT CHIP ──────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            )),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: color.withOpacity(0.3), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─── CYBER DIVIDER ──────────────────────────────────────────
class CyberDivider extends StatelessWidget {
  final Color? color;
  const CyberDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            c.withOpacity(0.3),
            c.withOpacity(0.5),
            c.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// ─── ANIMATED PAGE ROUTE ────────────────────────────────────
class FadeRoute extends PageRouteBuilder {
  FadeRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// ─── SCALE PAGE ROUTE ───────────────────────────────────────
class ScaleRoute extends PageRouteBuilder {
  ScaleRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, a, __, child) =>
              ScaleTransition(scale: a, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        );
}

/// ─── SLIDE UP ROUTE ─────────────────────────────────────────
class SlideUpRoute extends PageRouteBuilder {
  SlideUpRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, a, __, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: a, child: child),
              ),
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// ─── ANIMATED BUILDER HELPER ────────────────────────────────
class AnimBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  /// Convenience constructor using `animation:` named parameter
  factory AnimBuilder.withAnimation({
    Key? key,
    required Animation<double> animation,
    required Widget Function(BuildContext context, Widget? child) builder,
  }) = AnimBuilder._fromAnimation;

  const AnimBuilder._fromAnimation({
    Key? key,
    required Animation<double> animation,
    required this.builder,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
