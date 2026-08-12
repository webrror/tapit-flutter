import 'dart:math' as math;
import 'package:flutter/material.dart';

class TapEffectItem {
  final Offset position;
  final Color color;
  final DateTime createdAt;
  final List<ParticleSpark> particles;

  TapEffectItem({
    required this.position,
    required this.color,
    required this.createdAt,
    required this.particles,
  });
}

class ParticleSpark {
  final double angle;
  final double speed;
  final double size;

  ParticleSpark({
    required this.angle,
    required this.speed,
    required this.size,
  });

  static List<ParticleSpark> generate(int count) {
    final random = math.Random();
    return List.generate(count, (_) {
      return ParticleSpark(
        angle: random.nextDouble() * 2 * math.pi,
        speed: 25.0 + random.nextDouble() * 45.0,
        size: 2.0 + random.nextDouble() * 2.5,
      );
    });
  }
}

class TapEffectPainter extends CustomPainter {
  final List<TapEffectItem> effects;
  final double animationValue;

  TapEffectPainter({
    required this.effects,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    for (final effect in effects) {
      final elapsedMs = now.difference(effect.createdAt).inMilliseconds;
      const totalDurationMs = 350.0;
      final progress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);

      if (progress >= 1.0) continue;

      final easeProgress = Curves.easeOutCubic.transform(progress);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      // 1. Draw expanding shockwave ring
      final ringPaint = Paint()
        ..color = effect.color.withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - progress) * 3.5 + 0.5;

      final ringRadius = 15.0 + (easeProgress * 55.0);
      canvas.drawCircle(effect.position, ringRadius, ringPaint);

      // 2. Draw center glow spot
      final glowPaint = Paint()
        ..color = effect.color.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(effect.position, (1.0 - progress) * 12.0, glowPaint);

      // 3. Draw bursting spark particles
      for (final particle in effect.particles) {
        final sparkDistance = easeProgress * particle.speed;
        final sparkX = effect.position.dx + math.cos(particle.angle) * sparkDistance;
        final sparkY = effect.position.dy + math.sin(particle.angle) * sparkDistance;

        final sparkPaint = Paint()
          ..color = effect.color.withValues(alpha: opacity * 0.9)
          ..style = PaintingStyle.fill;

        final sparkRadius = particle.size * (1.0 - progress);
        canvas.drawCircle(Offset(sparkX, sparkY), sparkRadius, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TapEffectPainter oldDelegate) => true;
}
