package ai.ayvalabs.pawme

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.auki/pose"

    private var isCalibratedToDomain = false
    private var mockInternalTicker = 0.0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLogging" -> {
                    val domainId = call.argument<String>("domainId") ?: "C5-510"
                    Log.d("AukiLog", "Session for Domain: $domainId")
                    isCalibratedToDomain = false
                    result.success("Session Initialized")
                }
                "triggerCalibrationMatch" -> {
                    Log.d("AukiLog", "Portal matched! Locking coordinates.")
                    isCalibratedToDomain = true
                    result.success(true)
                }
                "getLatestPose" -> {
                    if (isCalibratedToDomain) {
                        mockInternalTicker += 0.05
                        if (mockInternalTicker > 10.0) mockInternalTicker = 0.0
                    }
                    val pose = HashMap<String, Any>()
                    pose["local_x"] = 0.4 + (mockInternalTicker * 0.02)
                    pose["local_y"] = -0.557
                    pose["local_z"] = -1.206 - (mockInternalTicker * 0.01)
                    pose["calibrated"] = isCalibratedToDomain
                    pose["grid_x"] = 1.707 + (mockInternalTicker * 0.02)
                    pose["grid_y"] = 0.021
                    pose["grid_z"] = -1.031 - (mockInternalTicker * 0.01)
                    result.success(pose)
                }
                else -> result.notImplemented()
            }
        }
    }
}