package com.renderrichtext.renderer

import android.graphics.Color
import android.text.SpannableStringBuilder
import com.renderrichtext.parser.MarkdownASTNode
import com.renderrichtext.spans.FactoidBackgroundSpan
import com.renderrichtext.spans.FactoidSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class FactoidRenderer(
  private val config: RendererConfig,
) : NodeRenderer {
  override fun render(
    node: MarkdownASTNode,
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
      factory.renderWithSpan(builder, {
        factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
      }) { start, end, _ ->
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
      }
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
