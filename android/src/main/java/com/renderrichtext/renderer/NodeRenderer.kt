package com.renderrichtext.renderer

import android.content.Context
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.MetricAffectingSpan
import com.renderrichtext.math.LatexErrorReporter
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.ImageSpan
import com.renderrichtext.styles.StyleConfig
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

interface NodeRenderer {
  fun render(
    node: TiptapASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
    factory: RendererFactory,
  )
}

data class RendererConfig(
  val style: StyleConfig,
  val onLatexError: LatexErrorReporter? = null,
)

class RendererFactory(
  private val config: RendererConfig,
  val context: Context,
  private val onImageSpanCreated: (ImageSpan) -> Unit,
) {
  val blockStyleContext = BlockStyleContext()

  val styleCache = SpanStyleCache(config.style)

  /**
   * Spans registered here are applied after the full document tree is rendered, so they
   * always end up after block-level spans in the SpannableStringBuilder's internal array.
   * See [BaselineShiftRenderer] for the root cause and the proper long-term fix.
   *
   * The range is kept as offsets. A renderer that inserts text into the builder after
   * its children rendered (the blockquote padding spacer) must report it through
   * [shiftDeferredSpans], so the recorded ranges keep following their text.
   */
  private class DeferredSpan(
    val span: MetricAffectingSpan,
    var start: Int,
    var end: Int,
  )

  private val deferredSpans = mutableListOf<DeferredSpan>()
  private val afterRenderActions = mutableListOf<(Spanned) -> Unit>()

  fun registerDeferredSpan(
    span: MetricAffectingSpan,
    start: Int,
    end: Int,
  ) {
    deferredSpans.add(DeferredSpan(span, start, end))
  }

  /** Runs [action] on the finished text, once every block-level span is in place. */
  fun runAfterRender(action: (Spanned) -> Unit) {
    afterRenderActions.add(action)
  }

  /** Call right after inserting [length] characters at [position] into the builder being rendered. */
  fun shiftDeferredSpans(
    position: Int,
    length: Int,
  ) {
    // Spans are registered in document order, so only the most recent ones can lie at
    // or after the insertion point.
    for (index in deferredSpans.indices.reversed()) {
      val deferred = deferredSpans[index]
      if (deferred.end <= position) break
      if (deferred.start >= position) deferred.start += length
      deferred.end += length
    }
  }

  fun flushDeferredSpans(builder: SpannableStringBuilder) {
    for (deferred in deferredSpans) {
      builder.setSpan(deferred.span, deferred.start, deferred.end, SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE)
    }
    deferredSpans.clear()
    afterRenderActions.forEach { it(builder) }
    afterRenderActions.clear()
  }

  fun resetForNewRender() {
    blockStyleContext.resetForNewRender()
    deferredSpans.clear()
    afterRenderActions.clear()
  }

  fun createImageSpan(
    imageUrl: String,
    isInline: Boolean,
    altText: String,
  ): ImageSpan =
    ImageSpan(
      context = context,
      imageUrl = imageUrl,
      styleConfig = config.style,
      isInline = isInline,
      altText = altText,
    )

  private val textRenderer = TextRenderer()
  private val lineBreakRenderer = LineBreakRenderer()
  private val softBreakRenderer = SoftBreakRenderer()

  private val renderers: Map<TiptapASTNode.NodeType, NodeRenderer> by lazy {
    buildMap {
      put(TiptapASTNode.NodeType.Paragraph, ParagraphRenderer(config))
      put(TiptapASTNode.NodeType.Heading, HeadingRenderer(config))
      put(TiptapASTNode.NodeType.Blockquote, BlockquoteRenderer(config))
      // A list-nested admonition falls back to the inline blockquote renderer
      // (no themed header); top-level admonitions use the segment container path.
      put(TiptapASTNode.NodeType.Admonition, BlockquoteRenderer(config))
      put(TiptapASTNode.NodeType.CodeBlock, CodeBlockRenderer(config))
      put(TiptapASTNode.NodeType.UnorderedList, ListRenderer(config, isOrdered = false))
      put(TiptapASTNode.NodeType.OrderedList, ListRenderer(config, isOrdered = true))
      put(TiptapASTNode.NodeType.ListItem, ListItemRenderer(config))
      put(TiptapASTNode.NodeType.Text, textRenderer)
      put(TiptapASTNode.NodeType.Link, LinkRenderer(config))
      put(TiptapASTNode.NodeType.Strong, StrongRenderer(config))
      put(TiptapASTNode.NodeType.Emphasis, EmphasisRenderer(config))
      put(TiptapASTNode.NodeType.Strikethrough, StrikethroughRenderer(config))
      put(TiptapASTNode.NodeType.Underline, UnderlineRenderer(config))
      put(TiptapASTNode.NodeType.Highlight, HighlightRenderer())
      put(TiptapASTNode.NodeType.Code, CodeRenderer(config))
      put(TiptapASTNode.NodeType.Factoid, FactoidRenderer(config))
      put(TiptapASTNode.NodeType.LineBreak, lineBreakRenderer)
      put(TiptapASTNode.NodeType.SoftBreak, softBreakRenderer)
      put(TiptapASTNode.NodeType.ThematicBreak, ThematicBreakRenderer(config))
      put(TiptapASTNode.NodeType.BlankLine, BlankLineRenderer(config))
    }
  }

  /**
   * Called by ImageRenderer to report a new span to the collector.
   */
  fun registerImageSpan(span: ImageSpan) {
    onImageSpanCreated(span)
  }

  fun getRenderer(node: TiptapASTNode): NodeRenderer =
    renderers[node.type] ?: run {
      android.util.Log.w("RendererFactory", "No renderer for: ${node.type}")
      textRenderer
    }

  fun renderChildren(
    node: TiptapASTNode,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
  ) {
    renderNodes(node.children, builder, onLinkPress, onLinkLongPress, onFactoidPress)
  }

  /**
   * Renders a flat list of sibling nodes in order, dispatching each to its
   * NodeRenderer. Renders a block's own child content directly - e.g. a GFM
   * blockquote's content once its nested block segments have been split out -
   * without wrapping it in a synthetic root node.
   */
  fun renderNodes(
    nodes: List<TiptapASTNode>,
    builder: SpannableStringBuilder,
    onLinkPress: ((String) -> Unit)?,
    onLinkLongPress: ((String) -> Unit)?,
    onFactoidPress: ((String) -> Unit)?,
  ) {
    nodes.forEach { node ->
      getRenderer(node).render(node, builder, onLinkPress, onLinkLongPress, onFactoidPress, this)
    }
  }

  /**
   * Improved helper for applying spans to blocks of text.
   */
  inline fun renderWithSpan(
    builder: SpannableStringBuilder,
    renderContent: () -> Unit,
    applySpan: (start: Int, end: Int, blockStyle: BlockStyle) -> Unit,
  ) {
    val start = builder.length
    renderContent()
    val end = builder.length

    if (end > start) {
      val blockStyle = blockStyleContext.requireBlockStyle()
      applySpan(start, end, blockStyle)
    }
  }
}
