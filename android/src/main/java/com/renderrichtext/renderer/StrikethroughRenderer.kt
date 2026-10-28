package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.StrikethroughSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class StrikethroughRenderer(
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
    factory.renderWithSpan(builder, { factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress) }) { start, end, blockStyle ->
      builder.setSpan(
        StrikethroughSpan(factory.styleCache.strikethroughColor),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }
  }
}
