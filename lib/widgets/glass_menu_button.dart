import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapit/services/settings_service.dart';

class GlassMenuButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final List<Color>? gradient;
  final double width;

  const GlassMenuButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.gradient,
    this.width = 320,
  });

  @override
  State<GlassMenuButton> createState() => _GlassMenuButtonState();
}

class _GlassMenuButtonState extends State<GlassMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryGradient = widget.gradient ??
        const [
          Color(0xFFFF6D00),
          Color(0xFF7C4DFF),
        ];

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        SettingsService.instance.triggerHaptic(HapticType.selection);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: () {
        SettingsService.instance.triggerHaptic(HapticType.light);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: primaryGradient.first.withValues(alpha: isDark ? 0.35 : 0.3),
                      blurRadius: _isPressed ? 8 : 18,
                      offset: Offset(0, _isPressed ? 2 : 6),
                    ),
                    BoxShadow(
                      color: primaryGradient.last.withValues(alpha: isDark ? 0.3 : 0.25),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: Offset(0, _isPressed ? 2 : 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: _isPressed ? 6 : 14,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: widget.isPrimary
                      ? LinearGradient(
                          colors: primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.white.withValues(alpha: 0.04),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.85),
                                  Colors.white.withValues(alpha: 0.55),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  border: Border.all(
                    color: widget.isPrimary
                        ? Colors.white.withValues(alpha: 0.35)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.9)),
                    width: widget.isPrimary ? 1.5 : 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isPrimary
                            ? Colors.white.withValues(alpha: 0.22)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : theme.colorScheme.primary.withValues(alpha: 0.10)),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.isPrimary
                            ? Colors.white
                            : (isDark ? Colors.white : theme.colorScheme.primary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.3,
                              color: widget.isPrimary
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF1E1E2E)),
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.isPrimary
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : (isDark
                                        ? Colors.white60
                                        : const Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Chevron indicator
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: widget.isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : (isDark
                              ? Colors.white38
                              : const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
