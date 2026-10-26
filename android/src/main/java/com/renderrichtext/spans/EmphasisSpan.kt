package com.renderrichtext.spans

import android.graphics.Typeface
import android.text.TextPaint
import android.text.style.MetricAffectingSpan
import com.renderrichtext.renderer.BlockStyle
import com.renderrichtext.renderer.SpanStyleCache
import com.renderrichtext.utils.text.extensions.applyColorPreserving

class EmphasisSpan(
  private val styleCache: SpanStyleCache,
  private val blockStyle: BlockStyle,
) : MetricAffectingSpan() {
  override fun updateDrawState(tp: TextPaint) {
    applyEmphasisStyle(tp)
    applyEmphasisColor(tp)
  }

  override fun updateMeasureState(tp: TextPaint) {
    applyEmphasisStyle(tp)
  }

  private fun applyEmphasisStyle(tp: TextPaint) {
    val currentTypeface = tp.typeface ?: Typeface.DEFAULT
    val isBold = (currentTypeface.style) and Typeface.BOLD != 0
    val style = if (isBold) Typeface.BOLD_ITALIC else Typeface.ITALIC
    tp.typeface =
      if (styleCache.emphasisFontFamily.isNotEmpty()) {
        val resolvedStyle = if (styleCache.emphasisFontStyle == "normal") Typeface.NORMAL else style
        styleCache.getTypeface(styleCache.emphasisFontFamily, resolvedStyle)
      } else if (styleCache.emphasisFontStyle == "normal") {
        currentTypeface
      } else {
        Typeface.create(currentTypeface, style)
      }
  }

  private fun applyEmphasisColor(tp: TextPaint) {
    val colorToUse = styleCache.getEmphasisColorFor(blockStyle.color, tp.color)
    tp.applyColorPreserving(colorToUse, *styleCache.colorsToPreserve)
  }
}
