package br.tiagohm.restler

import android.os.Bundle
import android.util.Log
// import com.flurry.android.FlurryAgent
// import com.flurry.android.FlurryPerformance
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    /*
    FlurryAgent.Builder()
            .withCaptureUncaughtExceptions(true)
            .withIncludeBackgroundSessionsInMetrics(true)
            .withLogLevel(Log.VERBOSE)
            .withPerformanceMetrics(FlurryPerformance.All)
            .withLogEnabled(true)
            .build(this, "4Y5XVXYKTB9GY33CB9BW")
    */
  }
}
