package com.github.yamill.orientation.listeners

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import com.facebook.common.logging.FLog
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.ReactConstants
import com.facebook.react.modules.core.DeviceEventManagerModule

class OrientationConfigListener internal constructor(
    reactContext: ReactContext,
    private val onGetCurrentActivity: () -> Activity?,
) : LifecycleEventListener {

    private val receiver = object : BroadcastReceiver() {

        override fun onReceive(context: Context, intent: Intent) {
            val newConfig = intent.getParcelableExtra<Configuration>(INTENT_VALUE_KEY)!!
            val orientationValue = if (newConfig.orientation == 1) {
                "PORTRAIT"
            } else {
                "LANDSCAPE"
            }
            val params = Arguments.createMap()
            params.putString("orientation", orientationValue)
            if (reactContext.hasActiveReactInstance()) {
                reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                    .emit("orientationDidChange", params)
            }
        }
    }

    override fun onHostResume() {
        val activity = onGetCurrentActivity()
        if (activity != null) {
            activity.registerReceiver(receiver, IntentFilter(INTENT_ACTION_CONFIG_CHANGED))
        } else {
            FLog.e(ReactConstants.TAG, "no activity to register receiver")
        }
    }

    override fun onHostPause() {
        val activity = onGetCurrentActivity()
        if (activity != null) {
            try {
                activity.unregisterReceiver(receiver)
            } catch (e: IllegalArgumentException) {
                FLog.e(ReactConstants.TAG, "receiver already unregistered", e)
            }
        } else {
            FLog.e(ReactConstants.TAG, "no activity to un-register receiver")
        }
    }

    override fun onHostDestroy() = Unit

    companion object {

        private const val INTENT_ACTION_CONFIG_CHANGED = "onConfigurationChanged"
        private const val INTENT_VALUE_KEY = "newConfig"

        @Suppress("unused")
        fun sendBroadcast(activity: Activity, newConfig: Configuration) {
            activity.sendBroadcast(
                Intent(INTENT_ACTION_CONFIG_CHANGED).also { intent ->
                    intent.putExtra(INTENT_VALUE_KEY, newConfig)
                }
            )
        }
    }
}
