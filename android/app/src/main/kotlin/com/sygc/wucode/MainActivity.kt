package com.sygc.wucode

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import com.sygc.wucode.brickfactory.GSITool // 导入 GSITool 类

class MainActivity: FlutterActivity() {
    private val INFO_CHANNEL = "com.example.app/info"
    private val GSITOOL_CHANNEL = "com.sygc.wucode.brickfactory/gsitool"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 处理 com.example.app/info Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INFO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkVersion" -> result.success(Build.VERSION.SDK_INT.toString())
                "getModel" -> result.success(Build.MODEL)
                else -> result.notImplemented()
            }
        }

        // 处理 com.sygc.wucode.brickfactory/gsitool Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GSITOOL_CHANNEL).setMethodCallHandler { call, result ->
            val gsiTool = GSITool() // 创建 GSITool 的实例
            when (call.method) {
                "wipe" -> {
                    gsiTool.wipe()
                    result.success(null)
                }
                "wipeData" -> {
                    gsiTool.wipeData()
                    result.success(null)
                }
                "rebootIntoDSU" -> {
                    gsiTool.rebootIntoDSU()
                    result.success(null)
                }
                "abortInstall" -> {
                    gsiTool.abortInstall()
                    result.success(null)
                }
                "getStatus" -> {
                    val status = gsiTool.getStatus()
                    val response = mapOf("isInstalled" to status.first, "isEnabled" to status.second)
                    result.success(response)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}