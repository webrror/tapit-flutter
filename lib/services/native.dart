import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('common');
  static Future<AppInfo> getAppInfo() async {
    final Map info = await _channel.invokeMethod('getAppInfo');
    return AppInfo(appName: info['appName'], version: info['version']);
  }
}

class AppInfo {
  String appName;
  String version;

  AppInfo({this.appName = '', this.version = ''});
}
