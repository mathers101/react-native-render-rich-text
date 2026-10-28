package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.ThematicBreakSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

class ThematicBreakRenderer(
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
    builder.ensureNewline()

    val start = builder.length

    builder.append(" \n")
    val end = builder.length

    val style = config.style.thematicBreakStyle

    builder.setSpan(
      ThematicBreakSpan(
        style.color,
        style.height,
        style.marginTop,
        style.marginBottom,
      ),
      start,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )
  }

  private fun SpannableStringBuilder.ensureNewline() {
    if (isNotEmpty() && this[length - 1] != '\n') {
      append('\n')
    }
  }
}
