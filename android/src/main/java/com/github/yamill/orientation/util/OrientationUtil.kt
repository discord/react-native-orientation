package com.github.yamill.orientation.util

import android.content.res.Configuration

object OrientationUtil {
    fun getOrientationString(orientation: Int) =
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
