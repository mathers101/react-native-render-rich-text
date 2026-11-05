package com.renderrichtext.spans

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.text.Spanned
import android.text.style.ReplacementSpan
import kotlin.math.ceil

/**
 * One unbreakable chip for a mention. Material chips stay on a single line, so the
 * whole `@name` is one replacement run: the line breaker wraps it as a unit, and the
 * horizontal padding is part of that width rather than a separate gap that can be
 * left behind on the previous line.
 *
 * Each line fragment of an iOS mention is its own rounded rect. Android does not
 * split the chip, which is how inline people-chips behave in Material text.
 */
class MentionChipSpan(
  private val backgroundColor: Int,
  private val textColor: Int,
  private val paddingX: Float,
  private val paddingY: Float,
) : ReplacementSpan() {
  private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
  private val rect = RectF()
  private var cachedSource: Typeface? = null
  private var cachedMedium: Typeface? = null

  override fun getSize(
    paint: Paint,
    text: CharSequence,
    start: Int,
    end: Int,
    fm: Paint.FontMetricsInt?,
  ): Int {
    var width = 0
    paint.usingMedium {
      if (fm != null) {
        paint.getFontMetricsInt(fm)
        val extra = ceil(paddingY).toInt()
        fm.ascent -= extra
        fm.top -= extra
        fm.descent += extra
        fm.bottom += extra
      }
      width = ceil(paint.measureText(text, start, end) + paddingX * 2f).toInt()
    }
    return width
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
    paint.usingMedium {
      val textWidth = paint.measureText(text, start, end)
      val metrics = paint.fontMetrics
      rect.set(
        x,
        y + metrics.ascent - paddingY,
        x + textWidth + paddingX * 2f,
        y + metrics.descent + paddingY,
      )
      val radius = 10f
      var fill = backgroundColor
      if (isPressed(text)) fill = darken(fill)
      if (Color.alpha(fill) > 0) {
        fillPaint.color = fill
        canvas.drawRoundRect(rect, radius, radius, fillPaint)
      }

      val previousColor = paint.color
      paint.color = textColor
      canvas.drawText(text, start, end, x + paddingX, y.toFloat(), paint)
      paint.color = previousColor
    }
  }

  private fun isPressed(text: CharSequence): Boolean {
    val spanned = text as? Spanned ?: return false
    val start = spanned.getSpanStart(this)
    val end = spanned.getSpanEnd(this)
    if (start < 0 || end <= start) return false
    return spanned.getSpans(start, end, MentionSpan::class.java).any { it.pressed }
  }

  private fun darken(color: Int): Int =
    Color.argb(
      Color.alpha(color),
      (Color.red(color) * PRESSED_DARKEN).toInt(),
      (Color.green(color) * PRESSED_DARKEN).toInt(),
      (Color.blue(color) * PRESSED_DARKEN).toInt(),
    )

  /**
   * Medium is the Android weight for a name in body text. API 28 keeps the surrounding
   * family. Older releases have no weight axis, so the face becomes sans-serif-medium.
   */
  private fun mediumTypeface(base: Typeface?): Typeface {
    if (cachedMedium != null && cachedSource === base) return cachedMedium!!
    val source = base ?: Typeface.SANS_SERIF
    val italic = source.style and Typeface.ITALIC != 0
    val created =
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        Typeface.create(source, 500, italic)
      } else {
        Typeface.create("sans-serif-medium", if (italic) Typeface.ITALIC else Typeface.NORMAL)
      }
    cachedSource = base
    cachedMedium = created
    return created
  }

  private inline fun Paint.usingMedium(block: () -> Unit) {
    val original = typeface
    typeface = mediumTypeface(original)
    try {
      block()
    } finally {
      typeface = original
    }
  }

  companion object {
    private const val PRESSED_DARKEN = 0.82f
  }
}
