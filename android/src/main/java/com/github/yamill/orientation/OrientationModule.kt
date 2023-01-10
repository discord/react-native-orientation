package com.github.yamill.orientation

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.util.Log
import android.view.OrientationEventListener
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.github.yamill.orientation.listeners.OrientationAutoRotateListener
import com.github.yamill.orientation.listeners.OrientationConfigListener
import com.github.yamill.orientation.listeners.OrientationListener


class OrientationModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    private enum class LockState(val orientationInt: Int) {
        LOCKED_PORTRAIT(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT),
        LOCKED_LANDSCAPE(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE),
        LOCKED_LANDSCAPE_LEFT(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE),
        LOCKED_LANDSCAPE_RIGHT(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE),
        UNLOCKED(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_SENSOR),
        UNSPECIFIED(
            orientationInt = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED,
        ),
    }

    private var lockState: LockState? = null

    private var autoRotateEnabled = false
    private var autoRotateIgnored = false

    override fun getName() = "Orientation"

    override fun getConstants(): Map<String, Any?> {
        val orientationInt = reactApplicationContext.resources.configuration.orientation
        val orientation = getOrientationString(orientationInt)

        return mapOf("initialOrientation" to orientation)
    }

    init {
        reactContext.addLifecycleEventListener(
            OrientationAutoRotateListener(reactContext) { autoRotateEnabled ->
                updateOrientation(autoRotateEnabled = autoRotateEnabled)
            }
        )
        reactContext.addLifecycleEventListener(
            OrientationConfigListener(reactContext) {
                currentActivity
            }
        )

        reactContext.addLifecycleEventListener(
            OrientationListener(reactContext) {
                currentActivity;
            }
        )


    }

    @Suppress("unused")
    @ReactMethod
    fun getOrientation(callback: Callback) {
        val orientationInt = reactApplicationContext.resources.configuration.orientation
        val orientation = getOrientationString(orientationInt)
        if (orientation == null) {
            callback.invoke(orientationInt, null)
        } else {
            callback.invoke(null, orientation)
        }
    }

    @Suppress("unused")
    @ReactMethod
    fun ignoreAutoRotate(ignoreAutoRotate: Boolean) {
        updateOrientation(autoRotateIgnored = ignoreAutoRotate)
    }

    @SuppressLint("SourceLockedOrientationActivity")
    @Suppress("unused")
    @ReactMethod
    fun lockToPortrait() {
        updateOrientation(lockState = LockState.LOCKED_PORTRAIT)
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscape() {
        updateOrientation(lockState = LockState.LOCKED_LANDSCAPE)
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscapeLeft() {
        updateOrientation(lockState = LockState.LOCKED_LANDSCAPE_LEFT)
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscapeRight() {
        updateOrientation(lockState = LockState.LOCKED_LANDSCAPE_RIGHT)
    }

    @Suppress("unused")
    @ReactMethod
    fun unlockAllOrientations() {
        updateOrientation(lockState = LockState.UNLOCKED)
    }

    private fun updateOrientation(
        lockState: LockState? = this.lockState,
        autoRotateEnabled: Boolean = this.autoRotateEnabled,
        autoRotateIgnored: Boolean = this.autoRotateIgnored,
    ) {
        if (this.lockState == lockState &&
            this.autoRotateEnabled == autoRotateEnabled &&
            this.autoRotateIgnored == autoRotateIgnored) {
            return
        } else {
            this.lockState = lockState
            this.autoRotateEnabled = autoRotateEnabled
            this.autoRotateIgnored = autoRotateIgnored
        }

        if (lockState == null) {
            return
        }

        // When enabled set to last requested orientation.
        val autoRotationEnabled = autoRotateEnabled || autoRotateIgnored
        if (autoRotationEnabled) {
            currentActivity?.requestedOrientation = lockState.orientationInt
        }

        // When disabled ensure we are unspecified.
        val autoRotationDisabled = !autoRotateEnabled && !autoRotateIgnored
        if  (autoRotationDisabled && lockState != LockState.UNSPECIFIED) {
            currentActivity?.requestedOrientation = LockState.UNSPECIFIED.orientationInt
        }
    }

    private fun getOrientationString(orientation: Int) =
        when (orientation) {
            Configuration.ORIENTATION_LANDSCAPE ->
                "LANDSCAPE"
            Configuration.ORIENTATION_PORTRAIT ->
                "PORTRAIT"
            Configuration.ORIENTATION_UNDEFINED ->
                "UNKNOWN"
            else ->
                null
        }
}
