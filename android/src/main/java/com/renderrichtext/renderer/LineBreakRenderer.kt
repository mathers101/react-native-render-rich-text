package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.MarkdownASTNode

class LineBreakRenderer : NodeRenderer {
  override fun render(
    node: MarkdownASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
    factory: RendererFactory,
  ) {
    builder.append("\n")
  }
}
