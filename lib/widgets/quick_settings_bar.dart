import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapit/services/settings_service.dart';

class QuickSettingsBar extends StatelessWidget {
  const QuickSettingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;

        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.65),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sound Toggle
                  _SettingIconButton(
                    icon: settings.isSoundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    isActive: settings.isSoundEnabled,
                    tooltip: settings.isSoundEnabled ? 'Sound: On' : 'Sound: Muted',
                    activeColor: const Color(0xFFFF9100),
                    onTap: () => settings.toggleSound(),
                  ),
                  const SizedBox(width: 4),

                  // Haptics Toggle
                  _SettingIconButton(
                    icon: settings.isHapticsEnabled
                        ? Icons.vibration_rounded
                        : Icons.phone_android_rounded,
                    isActive: settings.isHapticsEnabled,
                    tooltip: settings.isHapticsEnabled ? 'Haptics: On' : 'Haptics: Off',
                    activeColor: const Color(0xFF00E5FF),
                    onTap: () => settings.toggleHaptics(),
                  ),
                  const SizedBox(width: 4),

                  // Theme Mode Cycle
                  _SettingIconButton(
                    icon: switch (settings.themeMode) {
                      ThemeMode.system => Icons.brightness_auto_rounded,
                      ThemeMode.light => Icons.wb_sunny_rounded,
                      ThemeMode.dark => Icons.nightlight_round,
                    },
                    isActive: true,
                    tooltip: switch (settings.themeMode) {
                      ThemeMode.system => 'Theme: Auto',
                      ThemeMode.light => 'Theme: Light',
                      ThemeMode.dark => 'Theme: Dark',
                    },
                    activeColor: const Color(0xFFB388FF),
                    onTap: () => settings.cycleThemeMode(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingIconButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final Color activeColor;
  final VoidCallback onTap;

  const _SettingIconButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_SettingIconButton> createState() => _SettingIconButtonState();
}

class _SettingIconButtonState extends State<_SettingIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive
                  ? widget.activeColor.withValues(alpha: isDark ? 0.22 : 0.15)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04)),
              border: Border.all(
                color: widget.isActive
                    ? widget.activeColor.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.isActive
                    ? (isDark ? widget.activeColor : widget.activeColor.withValues(alpha: 0.95))
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
