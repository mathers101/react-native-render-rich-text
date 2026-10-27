package com.renderrichtext.events

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class FactoidPressEvent(
  surfaceId: Int,
  viewId: Int,
  private val factoidId: String,
) : Event<FactoidPressEvent>(surfaceId, viewId) {
  override fun getEventName(): String = EVENT_NAME

  override fun getEventData(): WritableMap {
    val eventData: WritableMap = Arguments.createMap()
    eventData.putString("factoidId", factoidId)
    return eventData
  }

  companion object {
    const val EVENT_NAME: String = "onFactoidPress"
  }
}
