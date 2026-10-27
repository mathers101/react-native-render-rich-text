package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import android.text.style.AlignmentSpan
import com.renderrichtext.parser.MarkdownASTNode
import com.renderrichtext.styles.ParagraphStyle
import com.renderrichtext.utils.text.extensions.containsBlockImage
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE
import com.renderrichtext.utils.text.span.applyLineHeightSkippingImages
import com.renderrichtext.utils.text.span.applyMarginBottom
import com.renderrichtext.utils.text.span.applyMarginTop

class ParagraphRenderer(
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
    val context = factory.blockStyleContext

    // Inside a list, render tight with a single newline - lists own their item spacing.
    if (context.listDepth > 0) {
      factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
      builder.append("\n")
      return
    }

    val start = builder.length
    val style = config.style.paragraphStyle

    // Inside a blockquote, keep the quote's block style (font/color) and line height
    // - applied by BlockquoteTextRenderer.postProcess - but still emit block margins so
    // spacing between blocks matches the top-level document (a heading defaults to
    // marginTop 0, so the gap before it comes from the preceding paragraph's marginBottom).
    if (context.blockquoteDepth > 0) {
      factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
      if (builder.length > start) {
        val marginTop = if (node.containsBlockImage()) config.style.imageStyle.marginTop else style.marginTop
        applyMarginTop(builder, start, marginTop)
        val marginBottom = if (node.containsBlockImage()) config.style.imageStyle.marginBottom else style.marginBottom
        applyMarginBottom(builder, marginBottom)
      }
      return
    }

    context.setParagraphStyle(style)
    try {
      factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
    } finally {
      context.popBlockStyle()
    }

    if (builder.length > start) {
      builder.applySpans(node, style, start)
    }
  }

  private fun SpannableStringBuilder.applySpans(
    node: MarkdownASTNode,
    style: ParagraphStyle,
    start: Int,
  ) {
    val end = length

    // TODO: LineHeightSpan may also clip superscript/subscript glyphs that extend
    // outside the normal line bounds. A similar "skip" strategy as for images may
    // be needed here once super/subscript usage in practice is better understood.
    applyLineHeightSkippingImages(this, start, end, style.lineHeight)

    // Only apply AlignmentSpan for non-default alignments (Center/Right)
    if (style.textAlign.needsAlignmentSpan) {
      setSpan(
        AlignmentSpan.Standard(style.textAlign.layoutAlignment),
        start,
        end,
        SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
      )
    }

    val marginTop = if (node.containsBlockImage()) config.style.imageStyle.marginTop else style.marginTop
    applyMarginTop(this, start, marginTop)

    val marginBottom = if (node.containsBlockImage()) config.style.imageStyle.marginBottom else style.marginBottom
    applyMarginBottom(this, marginBottom)
  }
}
