package com.sailinglogbook.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var alarm: AlarmChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        alarm = AlarmChannel(
            this,
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                AlarmChannel.CHANNEL,
            ),
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        // The sound picker answers here. Anything the alarm does not claim is
        // passed on — plugins (camera, file picker) use this same callback.
        if (alarm?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        alarm?.dispose()
        alarm = null
        super.onDestroy()
    }
}
