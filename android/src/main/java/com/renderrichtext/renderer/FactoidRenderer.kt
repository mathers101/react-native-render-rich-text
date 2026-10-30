package com.renderrichtext.renderer

import android.graphics.Color
import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.FactoidBackgroundSpan
import com.renderrichtext.spans.FactoidPaddingSpan
import com.renderrichtext.spans.FactoidSpan
import com.renderrichtext.spans.LinkPillSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class FactoidRenderer(
  private val config: RendererConfig,
) : NodeRenderer {
  override fun render(
    node: TiptapASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
    factory: RendererFactory,
  ) {
    // Node attributes replace one channel. Otherwise the spans use the same objects code uses:
    // SpanStyleCache for the text color, StyleConfig for the background and border.
    val textColor = node.getAttribute("color").toColorOrNull()
    val backgroundColor = node.getAttribute("backgroundColor").toColorOrNull()
    val borderColor = node.getAttribute("borderColor").toColorOrNull()
    val factoidId = node.getAttribute("id").orEmpty()

    // Children are inline nodes (text, marks, links). Push the text color onto the block style
    // so they keep the surrounding font and pick up this color as their base.
    factory.blockStyleContext.pushInlineColor(textColor ?: factory.styleCache.factoidColor)
    try {
      val contentStart = builder.length
      factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
      val contentEnd = builder.length
      if (contentEnd == contentStart) return

      // A pill already has its own padding and is punched out of this background.
      // A gap on that edge would draw as a sliver beside the pill.
      val padLeading = !coveredByPill(builder, contentStart, contentStart + 1)
      val padTrailing = !coveredByPill(builder, contentEnd - 1, contentEnd)
      if (padLeading) {
        builder.insert(contentStart, FactoidPaddingSpan.MARK.toString())
        factory.shiftDeferredSpans(contentStart, 1)
      }
      if (padTrailing) builder.append(FactoidPaddingSpan.MARK)
      val start = contentStart
      val end = builder.length
      if (padLeading) {
        builder.setSpan(FactoidPaddingSpan(), start, start + 1, SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE)
      }
      if (padTrailing) {
        builder.setSpan(FactoidPaddingSpan(), end - 1, end, SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE)
      }
      builder.setSpan(
        FactoidSpan(factory.styleCache, factoidId, onFactoidPress, textColor),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
      builder.setSpan(
        FactoidBackgroundSpan(config.style, backgroundColor, borderColor),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    } finally {
      factory.blockStyleContext.popInlineColor()
    }
  }

  private fun coveredByPill(
    builder: SpannableStringBuilder,
    start: Int,
    end: Int,
  ): Boolean = builder.getSpans(start, end, LinkPillSpan::class.java).isNotEmpty()
}

private fun String?.toColorOrNull(): Int? {
  val value = this?.trim().orEmpty()
  if (value.isEmpty()) return null
  return try {
    Color.parseColor(value)
  } catch (_: IllegalArgumentException) {
    null
  }
}
