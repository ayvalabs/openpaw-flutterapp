import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── NEON PALETTE (more vibrant) ─────────────────────────────
  static const Color primary = Color(0xFF8B5CF6);       // Brighter vivid purple
  static const Color primaryLight = Color(0xFFA78BFA);   // Soft purple
  static const Color primaryDark = Color(0xFF6D28D9);    // Deep purple

  static const Color accent = Color(0xFF22D3EE);         // Bright neon cyan
  static const Color accentLight = Color(0xFF67E8F9);    // Cyan light
  static const Color accentGreen = Color(0xFF34D399);    // Neon green
  static const Color accentPink = Color(0xFFF472B6);     // Neon pink
  static const Color accentOrange = Color(0xFFFB923C);   // Neon orange
  static const Color accentYellow = Color(0xFFFBBF24);   // Neon yellow

  // ─── DARK SURFACES ──────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF03050D);  // Deeper bg (near black)
  static const Color surfaceDark = Color(0xFF0B0F1A);     // Card bg
  static const Color cardDark = Color(0xFF111827);        // Elevated card
  static const Color cardBorder = Color(0xFF1F2937);      // Subtle border
  static const Color overlayDark = Color(0x1AFFFFFF);     // White 10%

  // ─── GLASS EFFECT ────────────────────────────────────────────
  static const Color glassBg = Color(0x14FFFFFF);        // Glass bg 8%
  static const Color glassBorder = Color(0x33FFFFFF);     // Glass border 20%
  static const Color glassHighlight = Color(0x0DFFFFFF);  // Glass highlight 5%

  // ─── TEXT ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF475569);
  static const Color textGlow = Color(0xFFE2E8F0);

  // ─── STATUS ─────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);

  // ─── GLOW HELPERS ───────────────────────────────────────────
  static List<BoxShadow> glow(Color c, {double intensity = 1.0}) => [
    BoxShadow(color: c.withOpacity(0.35 * intensity), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: c.withOpacity(0.12 * intensity), blurRadius: 32, spreadRadius: 4),
    BoxShadow(color: c.withOpacity(0.05 * intensity), blurRadius: 48, spreadRadius: 8),
  ];

  static List<BoxShadow> glowPurple = [
    BoxShadow(color: primary.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: primary.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];

  static List<BoxShadow> glowCyan = [
    BoxShadow(color: accent.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: accent.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];

  static List<BoxShadow> glowGreen = [
    BoxShadow(color: accentGreen.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: accentGreen.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];

  static List<BoxShadow> glowPink = [
    BoxShadow(color: accentPink.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: accentPink.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];

  static List<BoxShadow> glowOrange = [
    BoxShadow(color: accentOrange.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: accentOrange.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];

  // ─── GRADIENTS ──────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cardDark.withOpacity(0.6),
      cardDark.withOpacity(0.3),
    ],
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF080C18),
      Color(0xFF050811),
      Color(0xFF03050D),
    ],
  );
}
