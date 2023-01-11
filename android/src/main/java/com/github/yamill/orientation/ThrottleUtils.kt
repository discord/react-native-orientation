package com.github.yamill.orientation

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * This is based on the throttleLatest implementation from
 * https://stackoverflow.com/questions/50858684/kotlin-android-debounce .
 */
fun <T, R> throttleLatest(
        intervalMs: Long = 300L,
        coroutineScope: CoroutineScope,
        destinationFunction: (T, R) -> Unit
): (T, R) -> Unit {
    var throttleJob: Job? = null
    var latestParam1: T
    var latestParam2: R
    return { param1: T, param2: R ->
        latestParam1 = param1
        latestParam2 = param2
        if (throttleJob?.isCompleted != false) {
            throttleJob = coroutineScope.launch {
                delay(intervalMs)
                destinationFunction.invoke(latestParam1, latestParam2)
            }
        }
    }
}
