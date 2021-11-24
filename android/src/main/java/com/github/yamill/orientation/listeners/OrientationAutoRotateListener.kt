package com.github.yamill.orientation.listeners

import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext

internal class OrientationAutoRotateListener(
    private val reactContext: ReactContext,
    private val onAutoRotateEnabled: (autoRotateEnabled: Boolean) -> Unit,
) : LifecycleEventListener {

    private val setting = Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION)

    private val autoRotateFlag = Settings.System.ACCELEROMETER_ROTATION
    private val autoRotate
        get() = Settings.System.getInt(reactContext.contentResolver, autoRotateFlag, 0) == 1

    private val observer: ContentObserver = object : ContentObserver(Handler(Looper.myLooper()!!)) {
        override fun onChange(selfChange: Boolean) {
            super.onChange(selfChange)

            onAutoRotateEnabled(autoRotate)
        }

        override fun deliverSelfNotifications(): Boolean {
            return true
        }
    }

    init {
        onAutoRotateEnabled(autoRotate)
    }

    override fun onHostResume() {
        reactContext.contentResolver.registerContentObserver(setting, false, observer)
    }

    override fun onHostPause() {
        reactContext.contentResolver.unregisterContentObserver(observer)
    }

    override fun onHostDestroy() {}
}