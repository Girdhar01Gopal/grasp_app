package com.example.grasp_app

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "rotation_lock"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isAutoRotateEnabled" -> {
						val autoRotate = Settings.System.getInt(
							contentResolver,
							Settings.System.ACCELEROMETER_ROTATION,
							0
						) == 1
						result.success(autoRotate)
					}

					else -> result.notImplemented()
				}
			}
	}
}
