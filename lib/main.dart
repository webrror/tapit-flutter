import 'package:flutter/material.dart';
import 'package:tapit/app.dart';
import 'package:tapit/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();
  runApp(const TapitApp());
}