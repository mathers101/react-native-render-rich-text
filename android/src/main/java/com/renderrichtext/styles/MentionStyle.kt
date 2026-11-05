package com.renderrichtext.styles

import com.facebook.react.bridge.ReadableMap

data class MentionStyle(
  val color: Int,
  val backgroundColor: Int,
) {
  companion object {
    fun fromReadableMap(
      map: ReadableMap,
      parser: StyleParser,
    ): MentionStyle {
      val color = parser.parseColor(map, "color")
      val backgroundColor = parser.parseColor(map, "backgroundColor")
      return MentionStyle(color, backgroundColor)
    }
  }
}
