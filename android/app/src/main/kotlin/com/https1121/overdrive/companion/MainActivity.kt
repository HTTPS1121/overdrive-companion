package com.https1121.overdrive.companion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        H264StreamPlugin.register(flutterEngine)
        PcmAudioPlugin.register(flutterEngine)
    }
}
