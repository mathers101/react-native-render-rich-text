package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.MarkdownASTNode
import com.renderrichtext.spans.CodeBackgroundSpan
import com.renderrichtext.spans.CodeSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class CodeRenderer(
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
    if (node.children.isEmpty() || node.children.all { it.content.isEmpty() }) return

    factory.renderWithSpan(builder, { node.children.forEach { builder.append(it.content) } }) { start, end, blockStyle ->
      builder.setSpan(
        CodeSpan(factory.styleCache, blockStyle),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
      builder.setSpan(
        CodeBackgroundSpan(config.style),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }
  }
}
