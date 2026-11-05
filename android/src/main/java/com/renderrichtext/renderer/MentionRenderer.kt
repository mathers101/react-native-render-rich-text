package com.renderrichtext.renderer

import android.text.SpannableStringBuilder
import com.facebook.react.uimanager.PixelUtil
import com.renderrichtext.parser.TiptapASTNode
import com.renderrichtext.spans.MentionChipSpan
import com.renderrichtext.spans.MentionSpan
import com.renderrichtext.spans.TextSpan
import com.renderrichtext.utils.text.span.SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE

/**
 * Tiptap mention atom. The node has no children; the visible text is `@` plus
 * `label`, or `id` when `label` is blank. That is the suggestion character the
 * Mention extension inserts.
 *
 * Weight is medium (`500`), the Android face used for a name inside body text.
 * iOS uses semibold for the same role.
 */
class MentionRenderer(
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
    val mentionId = node.getAttribute("id").orEmpty()
    val label = node.getAttribute("label").orEmpty()
    val name = label.ifBlank { mentionId }
    val text = "@$name"
    val mentionStyle = config.style.mentionStyle
    val block = factory.blockStyleContext.currentBlockStyleOrNull()
    val fontSize = block?.fontSize ?: config.style.paragraphStyle.fontSize
    val fontFamily = block?.fontFamily ?: config.style.paragraphStyle.fontFamily

    val start = builder.length
    builder.append(text)
    val end = builder.length
    builder.setSpan(
      TextSpan(
        BlockStyle(
          fontSize = fontSize,
          fontFamily = fontFamily,
          fontWeight = "500",
          color = mentionStyle.color,
        ),
        factory.context,
      ),
      start,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )
    builder.setSpan(
      MentionSpan(
        mentionId,
        label,
        mentionStyle.color,
        factory.onMentionPress,
        factory.onMentionLongPress,
      ),
      start,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )
    builder.setSpan(
      MentionChipSpan(
        backgroundColor = mentionStyle.backgroundColor,
        textColor = mentionStyle.color,
        paddingX = PixelUtil.toPixelFromDIP(PADDING_X_DP),
        paddingY = PixelUtil.toPixelFromDIP(PADDING_Y_DP),
      ),
      start,
      end,
      SPAN_FLAGS_EXCLUSIVE_EXCLUSIVE,
    )
  }

  companion object {
    private const val PADDING_X_DP = 3f
    private const val PADDING_Y_DP = 1f
  }
}
