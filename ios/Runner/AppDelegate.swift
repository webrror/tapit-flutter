import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let commonChannel = FlutterMethodChannel(
      name: "common",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    commonChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "getAppInfo":
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
          ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
          ?? "Tapit"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appInfo: [String: Any] = [
          "appName": appName,
          "version": version
        ]
        result(appInfo)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }
}
