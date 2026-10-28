package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode

class SoftBreakRenderer : NodeRenderer {
  override fun render(
    node: TiptapASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
    factory: RendererFactory,
  ) {
    builder.append(" ")
  }
}
