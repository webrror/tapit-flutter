package com.rejie.tapit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val commonChannel = "common"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, commonChannel).setMethodCallHandler { call, result ->
            when(call.method) {
                "getAppInfo" -> {
                    try {
                        val packageManager = applicationContext.packageManager
                        val packageInfo = packageManager.getPackageInfo(packageName, 0)
                        val appName = applicationContext.applicationInfo.loadLabel(packageManager).toString()
                        val versionName = packageInfo.versionName

                        val appInfo = mapOf(
                            "appName" to appName,
                            "version" to versionName
                        )
                        result.success(appInfo)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "App info not available.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
