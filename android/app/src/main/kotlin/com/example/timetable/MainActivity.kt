package com.example.timetable

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.timetable/intent"
    private var initialIntentPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        handleIntent(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialIntent") {
                result.success(initialIntentPath)
                initialIntentPath = null // Consume it
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        // If app is already running, we should ideally notify Flutter immediately.
        // For simplicity, we'll store it and let Flutter poll or we can invoke a method.
        initialIntentPath?.let { path ->
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onNewIntent", path)
                initialIntentPath = null
            }
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_SEND == action && type != null) {
            (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                initialIntentPath = readContentFromUri(uri)
            }
        } else if (Intent.ACTION_VIEW == action) {
            intent.data?.let { uri ->
                initialIntentPath = readContentFromUri(uri)
            }
        }
    }

    private fun readContentFromUri(uri: Uri): String? {
        return try {
            contentResolver.openInputStream(uri)?.use { inputStream ->
                inputStream.bufferedReader().use { it.readText() }
            }
        } catch (e: Exception) {
            null
        }
    }
}
