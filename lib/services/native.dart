import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('common');
  static Future<AppInfo> getAppInfo() async {
    try {
      final Map? info = await _channel.invokeMapMethod<String, dynamic>('getAppInfo');
      if (info != null) {
        return AppInfo(
          appName: info['appName']?.toString() ?? 'Tapit',
          version: info['version']?.toString() ?? '',
        );
      }
    } catch (_) {}
    return AppInfo(appName: 'Tapit', version: '');
  }
}

class AppInfo {
  String appName;
  String version;

  AppInfo({this.appName = '', this.version = ''});
}
