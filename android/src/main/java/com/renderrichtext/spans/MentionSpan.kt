package com.renderrichtext.spans

import android.text.TextPaint
import android.text.style.ClickableSpan
import android.view.View
import com.renderrichtext.EnrichedTiptapText

/**
 * Click and long-press target for a mention. The chip span draws the glyphs, so this
 * only supplies the text color and the gestures. No underline: a mention is a chip,
 * not a link.
 */
class MentionSpan(
  val mentionId: String,
  val label: String,
  private val textColor: Int,
  private val onMentionPress: ((String, String) -> Unit)?,
  private val onMentionLongPress: ((String, String) -> Unit)?,
) : ClickableSpan() {
  /** True while a finger is down on this mention. The chip reads it while drawing. */
  var pressed: Boolean = false

  @Volatile
  private var longPressTriggered = false

  override fun onClick(widget: View) {
    if (longPressTriggered) {
      longPressTriggered = false
      return
    }
    onMentionPress?.invoke(mentionId, label)
      ?: (widget as? EnrichedTiptapText)?.emitOnMentionPress(mentionId, label)
  }

  fun onLongClick(widget: View): Boolean {
    longPressTriggered = true
    onMentionLongPress?.invoke(mentionId, label)
      ?: (widget as? EnrichedTiptapText)?.emitOnMentionLongPress(mentionId, label)
    return true
  }

  override fun updateDrawState(textPaint: TextPaint) {
    textPaint.color = textColor
    textPaint.isUnderlineText = false
  }
}
