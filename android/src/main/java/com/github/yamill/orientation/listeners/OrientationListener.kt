package com.github.yamill.orientation.listeners

import android.app.Activity
import android.view.OrientationEventListener
import com.facebook.common.logging.FLog
import com.facebook.react.bridge.Arguments
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.ReactConstants
import com.github.yamill.orientation.throttleLatest
import kotlinx.coroutines.GlobalScope

class OrientationListener internal constructor(
        private val reactContext: ReactContext,
        private val onGetCurrentActivity: () -> Activity?,
) : LifecycleEventListener {

    private lateinit var orientationEventListener: OrientationEventListener;

    override fun onHostResume() {
        val activity = onGetCurrentActivity()
        if (activity != null && !this::orientationEventListener.isInitialized) {
            orientationEventListener = object: OrientationEventListener(activity) {
                /**
                 * See https://developer.android.com/reference/android/view/OrientationEventListener#onOrientationChanged(int)
                 * for the range of orientationDegrees values.
                 */
                override fun onOrientationChanged(orientationDegrees: Int) {
                    onOrientationDegreesChange(orientationDegrees, reactContext)
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

    companion object {
        var lastEmittedOrientationDegrees: Int? = null

        val onOrientationDegreesChange: (Int, ReactContext) -> Unit = throttleLatest(
                intervalMs = 1000L,
                coroutineScope = GlobalScope,
                ::tryEmitOrientationDegreesChange
        )

        private fun tryEmitOrientationDegreesChange(orientationDegrees: Int, reactContext: ReactContext) {
            if (reactContext.hasActiveReactInstance()) {
                val params = Arguments.createMap()

                if (orientationDegrees != lastEmittedOrientationDegrees) {
                    params.putInt("orientationDegrees", orientationDegrees)
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                            .emit("orientationDegreesDidChange", params)

                    lastEmittedOrientationDegrees = orientationDegrees
                }
            }
        }
    }
}
