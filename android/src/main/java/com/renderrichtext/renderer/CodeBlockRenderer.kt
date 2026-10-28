package com.renderrichtext.renderer

import android.graphics.Paint
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.LineHeightSpan
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.CodeBlockSpan
import com.renderrichtext.spans.MarginBottomSpan
import com.renderrichtext.spans.isLastDrawnLine
import com.renderrichtext.utils.common.CodeBlockHighlighter
import com.renderrichtext.utils.common.CodeBlockNode
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE
import com.renderrichtext.utils.text.span.applyMarginTop

class CodeBlockRenderer(
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
    if (builder.isNotEmpty() && builder.last() != '\n') {
      builder.append("\n")
    }

    val start = builder.length
    val style = config.style.codeBlockStyle
    val context = factory.blockStyleContext

    applyMarginTop(builder, start, style.marginTop)

    // Content starts after the potential 1-character marginTop spacer
    val contentStart = start + (if (style.marginTop > 0) 1 else 0)

    context.setCodeBlockStyle(style)

    try {
      factory.renderChildren(node, builder, onLinkPress, onLinkLongPress, onFactoidPress)
    } finally {
      context.popBlockStyle()
    }

    if (builder.length == contentStart) return

    CodeBlockHighlighter.highlight(
      builder,
      CodeBlockNode.extractCode(node),
      CodeBlockNode.language(node),
      style,
      contentStart,
    )

    // Terminate the content so the margin newline below is its own line. Sharing
    // the last code line makes that line's descent grow by marginBottom, and the
    // background paints the whole line — the bottom edge is then the margin, and
    // it is not recognized as the last line, so the bottom corners stay square.
    if (builder.last() != '\n') {
      builder.append('\n')
    }

    val end = builder.length
    val padding = style.padding.toInt()

    // Apply background, borders, and horizontal padding to content only
    builder.setSpan(
      CodeBlockSpan(
        style,
        factory.context,
        factory.styleCache,
        context.accumulatedIndent,
        CodeBlockNode.extractCode(node),
        CodeBlockNode.language(node) ?: "",
      ),
      contentStart,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )

    // Apply vertical padding via line height manipulation
    builder.setSpan(
      CodeBlockBoundaryPaddingSpan(padding),
      contentStart,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )

    val marginStart = builder.length
    builder.append("\n")
    builder.setSpan(
      MarginBottomSpan(style.marginBottom),
      marginStart,
      builder.length,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )
  }

  /**
   * Internal span to handle top/bottom padding by modifying font metrics.
   */
  private class CodeBlockBoundaryPaddingSpan(
    private val padding: Int,
  ) : LineHeightSpan {
    override fun chooseHeight(
      text: CharSequence,
      startLine: Int,
      endLine: Int,
      spanstartv: Int,
      v: Int,
      fm: Paint.FontMetricsInt,
    ) {
      if (text !is Spanned) return

      val spanStart = text.getSpanStart(this)
      val spanEnd = text.getSpanEnd(this)

      // Adjust ascent/top for the first line to create internal top padding
      if (startLine == spanStart) {
        fm.ascent -= padding
        fm.top -= padding
      }

      // Same last-line test as CodeBlockSpan, so the bottom padding lands on the
      // line that draws the bottom corners.
      if (isLastDrawnLine(text, endLine, spanEnd)) {
        fm.descent += padding
        fm.bottom += padding
      }
    }
  }
}
