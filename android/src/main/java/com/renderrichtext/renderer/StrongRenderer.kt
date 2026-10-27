package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.MarkdownASTNode
import com.renderrichtext.spans.StrongSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class StrongRenderer(
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
    factory.renderWithSpan(builder, { factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress) }) { start, end, blockStyle ->
      builder.setSpan(
        StrongSpan(factory.styleCache, blockStyle),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }
  }
}
