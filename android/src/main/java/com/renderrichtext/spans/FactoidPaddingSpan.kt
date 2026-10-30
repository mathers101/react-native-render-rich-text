package com.renderrichtext.spans

import android.graphics.Canvas
import android.graphics.Paint
import android.text.Spanned
import android.text.style.ReplacementSpan

/**
 * A few pixels of advance at one edge of a factoid. The background is measured
 * from the layout, so the glyphs sit inside the span and the next run starts
 * after it.
 *
 * The character is a word joiner: no break on either side, and not whitespace,
 * so the gap stays attached to the text when the line wraps.
 */
internal class FactoidPaddingSpan : ReplacementSpan() {
  override fun getSize(
    paint: Paint,
    text: CharSequence,
    start: Int,
    end: Int,
    fm: Paint.FontMetricsInt?,
  ): Int = WIDTH

  override fun draw(
    canvas: Canvas,
    text: CharSequence,
    start: Int,
    end: Int,
    x: Float,
    top: Int,
    y: Int,
    bottom: Int,
    paint: Paint,
  ) = Unit

  companion object {
    const val WIDTH = 8
    const val MARK = '\u2060'
  }
}

/** Drops factoid padding marks. A word joiner that came from the document stays. */
internal fun CharSequence.stripFactoidPadding(): String {
  val spanned = this as? Spanned ?: return toString()
  val spans = spanned.getSpans(0, length, FactoidPaddingSpan::class.java)
  if (spans.isEmpty()) return toString()
  val skip = BooleanArray(length)
  for (span in spans) {
    val spanStart = spanned.getSpanStart(span).coerceAtLeast(0)
    val spanEnd = spanned.getSpanEnd(span).coerceAtMost(length)
    for (index in spanStart until spanEnd) skip[index] = true
  }
  val out = StringBuilder(length)
  for (index in 0 until length) {
    if (!skip[index]) out.append(this[index])
  }
  return out.toString()
}
