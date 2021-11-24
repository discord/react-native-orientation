package com.github.yamill.orientation

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

@Suppress("unused")
abstract class OrientationPackage : ReactPackage {

    override fun createNativeModules(reactContext: ReactApplicationContext) =
        listOf<NativeModule>(
            OrientationModule(reactContext)
        )

    override fun createViewManagers(reactContext: ReactApplicationContext) =
        emptyList<ViewManager<*, *>>()
}