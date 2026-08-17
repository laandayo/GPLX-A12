package com.gplx.xemay

import android.os.Build
import android.os.Bundle
import android.view.Display
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Use the supported AndroidX API on every Android version. Flutter's
        // SafeArea/MediaQuery then receives the system-bar and cutout insets.
        WindowCompat.enableEdgeToEdge(window)
    }

    override fun onResume() {
        super.onResume()
        requestHighestRefreshRate()
    }

    @Suppress("DEPRECATION")
    private fun requestHighestRefreshRate() {
        val layoutParams = window.attributes

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = window.decorView.display ?: return
            layoutParams.preferredRefreshRate = display.supportedModes
                .maxOfOrNull(Display.Mode::getRefreshRate)
                ?: display.refreshRate
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val display = windowManager.defaultDisplay
            layoutParams.preferredRefreshRate = display.refreshRate
        }

        window.attributes = layoutParams
    }
}
