package com.github.yamill.orientation

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.github.yamill.orientation.listeners.OrientationAutoRotateListener
import com.github.yamill.orientation.listeners.OrientationConfigListener


class OrientationModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

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
                this.autoRotateEnabled = autoRotateEnabled
                this.maybeLockToPortrait()
            }
        )
        reactContext.addLifecycleEventListener(
            OrientationConfigListener(reactContext) {
                currentActivity
            }
        )
    }

    @Suppress("unused")
    @ReactMethod
    fun getOrientation(callback: Callback) {
        val orientationInt = reactApplicationContext.resources.configuration.orientation
        val orientation = getOrientationString(orientationInt)
        if (orientation === "null") {
            callback.invoke(orientationInt, null)
        } else {
            callback.invoke(null, orientation)
        }
    }

    @Suppress("unused")
    @ReactMethod
    fun ignoreAutoRotate(ignoreAutoRotate: Boolean) {
        this.autoRotateIgnored = ignoreAutoRotate
        this.maybeLockToPortrait()
    }

    @SuppressLint("SourceLockedOrientationActivity")
    @Suppress("unused")
    @ReactMethod
    fun lockToPortrait() {
        currentActivity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscape() {
        if (autoRotateEnabled || autoRotateIgnored) {
            currentActivity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
        }
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscapeLeft() {
        if (autoRotateEnabled || autoRotateIgnored) {
            currentActivity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        }
    }

    @Suppress("unused")
    @ReactMethod
    fun lockToLandscapeRight() {
        if (autoRotateEnabled || autoRotateIgnored) {
            currentActivity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
        }
    }

    @Suppress("unused")
    @ReactMethod
    fun unlockAllOrientations() {
        if (autoRotateEnabled || autoRotateIgnored) {
            currentActivity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR
        }
    }

    private fun maybeLockToPortrait() {
        if (autoRotateEnabled || autoRotateIgnored) {
            return
        }

        lockToPortrait()
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