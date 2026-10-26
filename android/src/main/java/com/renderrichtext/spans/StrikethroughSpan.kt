package com.renderrichtext.spans

import android.text.TextPaint
import android.text.style.CharacterStyle

class StrikethroughSpan(
  private val strikethroughColor: Int,
) : CharacterStyle() {
  override fun updateDrawState(tp: TextPaint) {
    tp.isStrikeThruText = true
  }
}
