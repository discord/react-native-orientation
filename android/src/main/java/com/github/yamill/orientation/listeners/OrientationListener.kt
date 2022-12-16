package com.github.yamill.orientation.listeners

import android.app.Activity
import android.util.Log
import com.facebook.common.logging.FLog
import android.view.OrientationEventListener
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.ReactConstants

class OrientationListener internal constructor(
        private val reactContext: ReactContext,
        private val onGetCurrentActivity: () -> Activity?,
) : LifecycleEventListener {

    private lateinit var orientationEventListener: OrientationEventListener;

    override fun onHostResume() {
        val activity = onGetCurrentActivity()
        if (activity != null && !this::orientationEventListener.isInitialized) {
            orientationEventListener = object: OrientationEventListener(activity) {
                override fun onOrientationChanged(orientation: Int) {
                    Log.d("pikachu", "orientation change from event listener. orientation: ${orientation}")
                }
            }

            if (orientationEventListener.canDetectOrientation()) {
                orientationEventListener.enable();
            }
        } else {
            FLog.e(ReactConstants.TAG, "no activity to register receiver")
        }

    }

    override fun onHostPause() = Unit
    override fun onHostDestroy() = Unit
}
