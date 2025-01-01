package com.chuishuimingyue.log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/info" // 确保与 Flutter 代码中的名称一致

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getSdkVersion" -> result.success(Build.VERSION.SDK_INT.toString())
                "getModel" -> result.success(Build.MODEL)
                else -> result.notImplemented()
            }
        }
    }
}