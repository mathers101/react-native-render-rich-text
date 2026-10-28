package com.renderrichtext.utils.common

import android.view.View
import com.renderrichtext.EnrichedTiptapText

fun View.findEnrichedTiptapTextAncestor(): EnrichedTiptapText? {
  var current: android.view.ViewParent? = parent
  while (current != null && current !is EnrichedTiptapText) current = current.parent
  return current as? EnrichedTiptapText
}
