package com.renderrichtext.spans

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.text.Layout
import com.renderrichtext.renderer.BlockStyle
import com.renderrichtext.renderer.SpanStyleCache
import com.renderrichtext.styles.ListStyle

class UnorderedListSpan(
  private val listStyle: ListStyle,
  depth: Int,
  context: Context,
  styleCache: SpanStyleCache,
  drawsMarker: Boolean = true,
  ancestorMarkerOffset: Float = 0f,
  parentMarkerWidth: Float? = null,
) : BaseListSpan(
    depth = depth,
    context = context,
    styleCache = styleCache,
    blockStyle =
      BlockStyle(
        fontSize = listStyle.fontSize,
        fontFamily = listStyle.fontFamily,
        fontWeight = listStyle.fontWeight,
        color = listStyle.color,
      ),
    marginLeft = listStyle.marginLeft,
    gapWidth = listStyle.gapWidth,
    drawsMarker = drawsMarker,
    ancestorMarkerOffset = ancestorMarkerOffset,
    parentMarkerWidth = parentMarkerWidth,
  ) {
  companion object {
    private val sharedBulletPaint =
      Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
      }
  }

  private val radius: Float = listStyle.bulletSize / 2f
  private val ringStrokeWidth: Float = radius * 0.3f
  // Same column an ordered list reserves for `99.`, so both lists indent equally.
  private val markerColumnWidth: Float = OrderedListSpan.defaultMarkerColumnWidth(listStyle, context)

  private fun configureBulletPaint(): Paint =
    sharedBulletPaint.apply {
      color = listStyle.bulletColor
      style = Paint.Style.FILL
      strokeWidth = 0f
    }

  override fun getMarkerWidth(): Float = markerColumnWidth

  override fun drawMarker(
    canvas: Canvas,
    paint: Paint,
    x: Int,
    dir: Int,
    top: Int,
    baseline: Int,
    bottom: Int,
    layout: Layout?,
    start: Int,
  ) {
    val bulletPaint = configureBulletPaint()
    // Right-align the bullet in the same column as a number, so its right edge
    // meets the gap instead of sitting halfway into it.
    val bulletX = x + (depth * marginLeft + ancestorMarkerOffset + markerColumnWidth - radius) * dir
    val bulletY = baseline + (markerFontMetrics.ascent + markerFontMetrics.descent) / 2f

    when (depth) {
      0 -> {
        canvas.drawCircle(bulletX, bulletY, radius, bulletPaint)
      }

      1 -> {
        bulletPaint.style = Paint.Style.STROKE
        bulletPaint.strokeWidth = ringStrokeWidth
        canvas.drawCircle(bulletX, bulletY, radius - ringStrokeWidth / 2f, bulletPaint)
      }

      else -> {
        canvas.drawRect(
          bulletX - radius,
          bulletY - radius,
          bulletX + radius,
          bulletY + radius,
          bulletPaint,
        )
      }
    }
  }
}
