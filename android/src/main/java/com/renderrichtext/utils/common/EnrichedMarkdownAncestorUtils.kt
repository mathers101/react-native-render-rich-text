package com.renderrichtext.utils.common

import android.view.View
import com.renderrichtext.EnrichedMarkdownText

fun View.findEnrichedMarkdownTextAncestor(): EnrichedMarkdownText? {
  var current: android.view.ViewParent? = parent
  while (current != null && current !is EnrichedMarkdownText) current = current.parent
  return current as? EnrichedMarkdownText
}
