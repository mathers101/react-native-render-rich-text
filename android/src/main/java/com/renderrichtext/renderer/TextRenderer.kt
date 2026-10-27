package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.MarkdownASTNode
import com.renderrichtext.spans.TextSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class TextRenderer : NodeRenderer {
  override fun render(
    node: MarkdownASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
    factory: RendererFactory,
  ) {
    val content = node.content
    if (content.isEmpty()) return

    val blockType = factory.blockStyleContext.currentBlockType

    factory.renderWithSpan(builder, { builder.append(content) }) { start, end, blockStyle ->
      builder.setSpan(
        TextSpan(blockStyle, factory.context),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }
  }
}
