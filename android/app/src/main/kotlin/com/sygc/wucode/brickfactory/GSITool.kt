package com.sygc.wucode.brickfactory

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.IOException

class GSITool {
    fun wipe() {
        try {
            Runtime.getRuntime().exec("su -c gsi_tool wipe").waitFor()
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    fun wipeData() {
        try {
            Runtime.getRuntime().exec("su -c gsi_tool wipe-data").waitFor()
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    fun rebootIntoDSU() {
        try {
            Runtime.getRuntime().exec("su -c am start-service -a com.android.dynsystem.ACTION_REBOOT_TO_DYN_SYSTEM -n com.android.dynsystem/.DynamicSystemInstallationService").waitFor()
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    fun abortInstall() {
        try {
            Runtime.getRuntime().exec("su -c am start-service -a com.android.dynsystem.ACTION_DISCARD_INSTALL -n com.android.dynsystem/.DynamicSystemInstallationService").waitFor()
            Runtime.getRuntime().exec("su -c am start-service -a com.android.dynsystem.ACTION_CANCEL_INSTALL -n com.android.dynsystem/.DynamicSystemInstallationService").waitFor()
            wipe()
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    fun getStatus(): Pair<Boolean, Boolean> {
        return try {
            val process = Runtime.getRuntime().exec("su -c gsi_tool status")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readLines()
            val isInstalled = output.contains("installed")
            val isEnabled = !output.contains("disabled") && isInstalled
            Pair(isInstalled, isEnabled)
        } catch (e: IOException) {
            e.printStackTrace()
            Pair(false, false) // 发生异常时返回默认值
        }
    }
}