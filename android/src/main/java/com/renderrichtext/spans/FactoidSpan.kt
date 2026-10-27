package com.renderrichtext.spans

import android.text.TextPaint
import android.text.style.ClickableSpan
import android.view.View
import com.renderrichtext.EnrichedMarkdownText
import com.renderrichtext.renderer.SpanStyleCache

/**
 * Click target for a factoid. The surrounding font is left alone. Text color is the cached
 * factoid color, the same value [com.renderrichtext.spans.CodeSpan] reads for inline code.
 * A link color already on the paint is left in place.
 */
class FactoidSpan(
  private val styleCache: SpanStyleCache,
  val factoidId: String,
  private val onFactoidPress: ((String) -> Unit)?,
  private val textColorOverride: Int? = null,
) : ClickableSpan() {
  override fun onClick(widget: View) {
    onFactoidPress?.invoke(factoidId) ?: (widget as? EnrichedMarkdownText)?.emitOnFactoidPress(factoidId)
  }

  override fun updateDrawState(textPaint: TextPaint) {
    val color = textColorOverride ?: styleCache.factoidColor
    if (textPaint.color != color && textPaint.color in styleCache.colorsToPreserve) return
    textPaint.color = color
  }
}
