package com.renderrichtext.events

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class MentionPressEvent(
  surfaceId: Int,
  viewId: Int,
  private val mentionId: String,
  private val label: String,
) : Event<MentionPressEvent>(surfaceId, viewId) {
  override fun getEventName(): String = EVENT_NAME

  override fun getEventData(): WritableMap {
    val eventData: WritableMap = Arguments.createMap()
    eventData.putString("mentionId", mentionId)
    eventData.putString("label", label)
    return eventData
  }

  companion object {
    const val EVENT_NAME: String = "onMentionPress"
  }
}
