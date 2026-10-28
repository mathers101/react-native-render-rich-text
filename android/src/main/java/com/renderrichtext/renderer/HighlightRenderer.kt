package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.HighlightSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class HighlightRenderer : NodeRenderer {
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
        HighlightSpan(factory.styleCache, blockStyle),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }
  }
}
