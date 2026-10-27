package com.renderrichtext.styles

import com.facebook.react.bridge.ReadableMap

data class FactoidStyle(
  val color: Int,
  val backgroundColor: Int,
  val borderColor: Int,
) {
  companion object {
    fun fromReadableMap(
      map: ReadableMap,
      parser: StyleParser,
    ): FactoidStyle {
      val color = parser.parseColor(map, "color")
      val backgroundColor = parser.parseColor(map, "backgroundColor")
      val borderColor = parser.parseColor(map, "borderColor")
      return FactoidStyle(color, backgroundColor, borderColor)
    }
  }
}
