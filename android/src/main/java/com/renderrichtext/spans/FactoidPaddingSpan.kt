package com.renderrichtext.spans

import android.graphics.Canvas
import android.graphics.Paint
import android.text.Spanned
import android.text.TextPaint
import android.text.style.CharacterStyle
import android.text.style.MetricAffectingSpan
import android.text.style.ReplacementSpan
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * Horizontal gap at one edge of a factoid. The background is measured from the
 * layout, so the glyphs sit inside the span and the next run starts after it.
 *
 * The gap is added to the edge word's advance. It is not its own character:
 * Android splits measurement at each metric-span boundary, so a padding character
 * before the word is an 8px run that fits on the previous line while the word
 * wraps. [getSize] reports the word plus the gap, and the line breaker wraps
 * that as one unit.
 */
internal class FactoidPaddingSpan(
  private val padStart: Boolean,
  private val padEnd: Boolean,
) : ReplacementSpan() {
  override fun getSize(
    paint: Paint,
    text: CharSequence,
    start: Int,
    end: Int,
    fm: Paint.FontMetricsInt?,
  ): Int {
    val spanned = text as? Spanned
    val spanStart = spanned?.getSpanStart(this)?.takeIf { it >= 0 } ?: start
    val spanEnd = spanned?.getSpanEnd(this)?.takeIf { it >= 0 } ?: end
    var width = 0f
    var metricsSet = false
    walk(text, start, end, paint) { runStart, runEnd, runPaint ->
      width += runPaint.measureText(text, runStart, runEnd)
      if (fm != null) {
        val metrics = runPaint.fontMetricsInt
        if (!metricsSet) {
          fm.ascent = metrics.ascent
          fm.descent = metrics.descent
          fm.top = metrics.top
          fm.bottom = metrics.bottom
          metricsSet = true
        } else {
          fm.ascent = min(fm.ascent, metrics.ascent)
          fm.top = min(fm.top, metrics.top)
          fm.descent = max(fm.descent, metrics.descent)
          fm.bottom = max(fm.bottom, metrics.bottom)
        }
      }
    }
    if (fm != null && !metricsSet) {
      paint.getFontMetricsInt(fm)
    }
    if (padStart && start <= spanStart) width += WIDTH
    if (padEnd && end >= spanEnd) width += WIDTH
    return ceil(width).toInt()
  }

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
  ) {
    val spanned = text as? Spanned
    val spanStart = spanned?.getSpanStart(this)?.takeIf { it >= 0 } ?: start
    val baseShift = (paint as? TextPaint)?.baselineShift ?: 0
    var cursor = x
    if (padStart && start <= spanStart) cursor += WIDTH
    walk(text, start, end, paint) { runStart, runEnd, runPaint ->
      val baseline = y + (runPaint.baselineShift - baseShift).toFloat()
      canvas.drawText(text, runStart, runEnd, cursor, baseline, runPaint)
      cursor += runPaint.measureText(text, runStart, runEnd)
    }
  }

  companion object {
    const val WIDTH = 8
    const val MARK = '\u2060'
  }
}

private const val MAX_GLUE = 64

/**
 * Where a leading or trailing gap attaches. [runStart] is the first text
 * character of the word (including same-line spaces); [runEnd] is just past it.
 * Neither range includes a line break.
 */
internal class FactoidEdge(
  val runStart: Int,
  val runEnd: Int,
)

internal fun leadingFactoidEdge(
  text: CharSequence,
  start: Int,
  end: Int,
): FactoidEdge? {
  var index = start
  while (index < end && isLineBreak(text[index])) index++
  if (index >= end) return null
  val runStart = index
  while (index < end && isInlineSpace(text[index])) index++
  if (index >= end || isLineBreak(text[index]) || text.replacementAt(index)) return null
  val runEnd = consumeForward(text, index, end)
  if (runEnd <= index) return null
  return FactoidEdge(runStart, runEnd)
}

internal fun trailingFactoidEdge(
  text: CharSequence,
  start: Int,
  end: Int,
): FactoidEdge? {
  var limit = end
  while (limit > start && isLineBreak(text[limit - 1])) limit--
  if (limit <= start) return null
  var wordEnd = limit
  while (wordEnd > start && isInlineSpace(text[wordEnd - 1])) wordEnd--
  if (wordEnd <= start || text.replacementAt(wordEnd - 1)) return null
  val wordStart = consumeBackward(text, start, wordEnd)
  if (wordStart >= wordEnd) return null
  return FactoidEdge(wordStart, limit)
}

private fun consumeForward(
  text: CharSequence,
  start: Int,
  end: Int,
): Int {
  if (start >= end) return start
  var index = Character.offsetByCodePoints(text, start, 1)
  var consumed = 1
  while (index < end && consumed < MAX_GLUE && !canBreakBefore(text, index)) {
    index = Character.offsetByCodePoints(text, index, 1)
    consumed++
  }
  return index
}

private fun consumeBackward(
  text: CharSequence,
  start: Int,
  end: Int,
): Int {
  if (end <= start) return end
  var index = end
  var consumed = 0
  while (index > start && consumed < MAX_GLUE) {
    if (consumed > 0 && canBreakBefore(text, index)) break
    index = Character.offsetByCodePoints(text, index, -1)
    consumed++
  }
  return index
}

private fun canBreakBefore(
  text: CharSequence,
  index: Int,
): Boolean {
  if (index <= 0 || index >= text.length) return false
  val codePoint = Character.codePointAt(text, index)
  val previous = Character.codePointBefore(text, index)
  if (Character.isWhitespace(previous) || previous == FactoidPaddingSpan.MARK.code) return true
  if (isCjk(codePoint) || isCjk(previous)) return true
  if (text.replacementAt(index)) return true
  return false
}

private fun isCjk(codePoint: Int): Boolean =
  codePoint in 0x2E80..0x9FFF || codePoint in 0xAC00..0xD7AF || codePoint in 0xF900..0xFAFF

private fun isLineBreak(c: Char): Boolean = c == '\n' || c == '\r' || c == '\u2028' || c == '\u2029'

private fun isInlineSpace(c: Char): Boolean = c.isWhitespace() && !isLineBreak(c)

private fun CharSequence.replacementAt(index: Int): Boolean {
  val spanned = this as? Spanned ?: return false
  if (index < 0 || index >= length) return false
  val next = index + 1
  return spanned.getSpans(index, next, ReplacementSpan::class.java).isNotEmpty()
}

private fun walk(
  text: CharSequence,
  start: Int,
  end: Int,
  paint: Paint,
  block: (runStart: Int, runEnd: Int, runPaint: TextPaint) -> Unit,
) {
  val spanned = text as? Spanned
  val base = if (paint is TextPaint) paint else TextPaint(paint)
  var index = start
  while (index < end) {
    if (text[index] == FactoidPaddingSpan.MARK) {
      index++
      continue
    }
    val transition = if (spanned == null) end else spanned.nextSpanTransition(index, end, CharacterStyle::class.java)
    var runEnd = index
    while (runEnd < transition && text[runEnd] != FactoidPaddingSpan.MARK) runEnd++
    if (runEnd == index) {
      index++
      continue
    }
    val runPaint = TextPaint(base)
    if (spanned != null) applyStyles(spanned, index, runEnd, runPaint)
    block(index, runEnd, runPaint)
    index = if (runEnd < transition) runEnd else transition
  }
}

private fun applyStyles(
  text: Spanned,
  start: Int,
  end: Int,
  paint: TextPaint,
) {
  val spans = text.getSpans(start, end, CharacterStyle::class.java)
  for (span in spans) {
    if (span is ReplacementSpan) continue
    if (span is MetricAffectingSpan) span.updateMeasureState(paint)
    span.updateDrawState(paint)
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
    for (index in spanStart until spanEnd) {
      if (this[index] == FactoidPaddingSpan.MARK) skip[index] = true
    }
  }
  val out = StringBuilder(length)
  for (index in 0 until length) {
    if (!skip[index]) out.append(this[index])
  }
  return out.toString()
}
