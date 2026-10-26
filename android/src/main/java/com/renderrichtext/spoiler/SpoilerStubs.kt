package com.renderrichtext.spoiler

import android.graphics.Canvas
import android.text.Spanned
import android.view.View
import com.renderrichtext.spans.SpoilerSpan

enum class SpoilerOverlay {
  NONE,
  PARTICLES,
  ;

  companion object {
    fun fromString(value: String?): SpoilerOverlay = NONE
  }
}

class SpoilerOverlayDrawer {
  fun draw(canvas: Canvas) {}

  fun stop() {}

  fun revealSpan(
    span: SpoilerSpan,
    onDone: () -> Unit,
  ) {
  }

  companion object {
    fun setupIfNeeded(
      view: View,
      text: CharSequence?,
      current: SpoilerOverlayDrawer?,
      overlay: SpoilerOverlay,
    ): SpoilerOverlayDrawer? = null
  }
}

interface SpoilerCapable {
  val spoilerOverlayDrawer: SpoilerOverlayDrawer?
}

fun Spanned.isConcealedBySpoiler(
  start: Int,
  end: Int,
): Boolean = false
