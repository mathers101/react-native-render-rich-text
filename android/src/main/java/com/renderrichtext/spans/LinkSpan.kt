package com.renderrichtext.spans

import android.content.Context
import android.graphics.Color
import android.text.TextPaint
import android.text.style.ClickableSpan
import android.view.View
import com.renderrichtext.EnrichedTiptapText
import com.renderrichtext.renderer.BlockStyle
import com.renderrichtext.renderer.SpanStyleCache
import com.renderrichtext.utils.text.extensions.applyBlockStyleFont

class LinkSpan(
  val url: String,
  private val onLinkPress: ((String) -> Unit)?,
  private val onLinkLongPress: ((String) -> Unit)?,
  private val styleCache: SpanStyleCache,
  private val blockStyle: BlockStyle,
  private val context: Context,
  val recognizedLink: Boolean = false,
  // A recognized code span keeps its code font unless a link or variant font is set.
  private val keepsCodeFont: Boolean = false,
) : ClickableSpan() {
  @Volatile
  private var longPressTriggered = false

  override fun onClick(widget: View) {
    if (longPressTriggered) {
      longPressTriggered = false
      return
    }

    onLinkPress?.invoke(url) ?: (widget as? EnrichedTiptapText)?.emitOnLinkPress(url)
  }

  fun onLongClick(widget: View): Boolean {
    longPressTriggered = true

    (widget as? EnrichedTiptapText)?.emitOnLinkLongPress(url)

    onLinkLongPress?.invoke(url)

    return true
  }

  override fun updateDrawState(textPaint: TextPaint) {
    super.updateDrawState(textPaint)

    val variant = styleCache.resolvedVariantForUrl(url)

    val fontFamily = variant?.fontFamily?.takeIf { it.isNotEmpty() } ?: styleCache.linkFontFamily
    if (fontFamily.isNotEmpty()) {
      textPaint.textSize = blockStyle.fontSize
      textPaint.applyBlockStyleFont(blockStyle.copy(fontFamily = fontFamily), context)
    } else if (!keepsCodeFont) {
      textPaint.textSize = blockStyle.fontSize
      textPaint.applyBlockStyleFont(blockStyle, context)
    }

    textPaint.color = variant?.color ?: styleCache.linkColor
    textPaint.isUnderlineText = variant?.underline ?: styleCache.linkUnderline

    val backgroundColor = variant?.backgroundColor ?: styleCache.linkBackgroundColor
    if (Color.alpha(backgroundColor) > 0) {
      textPaint.bgColor = backgroundColor
    }
  }
}
