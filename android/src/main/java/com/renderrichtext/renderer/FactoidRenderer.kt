package com.renderrichtext.renderer

import android.graphics.Color
import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.FactoidBackgroundSpan
import com.renderrichtext.spans.FactoidPaddingSpan
import com.renderrichtext.spans.FactoidSpan
import com.renderrichtext.spans.leadingFactoidEdge
import com.renderrichtext.spans.trailingFactoidEdge
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

      // The gap is extra advance on the edge word, not its own character. A character
      // is a separate metric run, and the line breaker will leave those 8px on the
      // previous line when the word wraps. A pill already has its own padding; the edge
      // helpers refuse a run that is already a replacement.
      val lead = leadingFactoidEdge(builder, contentStart, contentEnd)
      val trail = trailingFactoidEdge(builder, contentStart, contentEnd)
      if (lead != null && trail != null && lead.runEnd >= trail.runStart) {
        builder.setSpan(
          FactoidPaddingSpan(padStart = true, padEnd = true),
          lead.runStart,
          trail.runEnd,
          SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
        )
      } else {
        if (lead != null) {
          builder.setSpan(
            FactoidPaddingSpan(padStart = true, padEnd = false),
            lead.runStart,
            lead.runEnd,
            SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
          )
        }
        if (trail != null) {
          builder.setSpan(
            FactoidPaddingSpan(padStart = false, padEnd = true),
            trail.runStart,
            trail.runEnd,
            SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
          )
        }
      }
      builder.setSpan(
        FactoidSpan(factory.styleCache, factoidId, onFactoidPress, textColor),
        contentStart,
        contentEnd,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
      builder.setSpan(
        FactoidBackgroundSpan(config.style, backgroundColor, borderColor),
        contentStart,
        contentEnd,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    } finally {
      factory.blockStyleContext.popInlineColor()
    }
  }
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
