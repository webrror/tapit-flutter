import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  static const String _keySound = 'setting_sound_enabled';
  static const String _keyHaptics = 'setting_haptics_enabled';
  static const String _keyTheme = 'setting_theme_mode';

  bool _isSoundEnabled = true;
  bool _isHapticsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticsEnabled => _isHapticsEnabled;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(_keySound) ?? true;
      _isHapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
      final themeIndex = prefs.getInt(_keyTheme);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
    _save();
  }

  Future<void> toggleHaptics() async {
    _isHapticsEnabled = !_isHapticsEnabled;
    if (_isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    notifyListeners();
    _save();
  }

  Future<void> cycleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
    }
    if (_isHapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    notifyListeners();
    _save();
  }

  void triggerHaptic(HapticType type) {
    if (!_isHapticsEnabled) return;
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
      case HapticType.medium:
        HapticFeedback.mediumImpact();
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
      case HapticType.selection:
        HapticFeedback.selectionClick();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySound, _isSoundEnabled);
      await prefs.setBool(_keyHaptics, _isHapticsEnabled);
      await prefs.setInt(_keyTheme, _themeMode.index);
    } catch (_) {}
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}
