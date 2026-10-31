package com.renderrichtext.accessibility

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.MotionEvent
import androidx.appcompat.widget.AppCompatTextView
import com.renderrichtext.spans.LinkPillSpan
import com.renderrichtext.utils.text.span.prepareWidthAwareSpans

/** AppCompatTextView with built-in TalkBack support via TiptapAccessibilityHelper. */
abstract class AccessibleTiptapTextView
  @JvmOverloads
  constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
  ) : AppCompatTextView(context, attrs, defStyleAttr) {
    val accessibilityHelper = TiptapAccessibilityHelper(this)

    /**
     * True only while [requestFocus] is on the stack. A tap focuses this view, and the
     * surrounding scroll view then brings the focused child on screen by its drawing
     * rect. This view is as tall as its text, so that scroll aligns the text with the
     * top of the viewport and the tapped line jumps upward. For that one call, the
     * drawing rect is the part already on screen, and the scroll delta is zero.
     * Dragging a selection still scrolls: that path asks for the caret's rectangle,
     * not this drawing rect.
     */
    private var reportingVisibleFocusRect = false

    override fun setText(
      text: CharSequence?,
      type: BufferType?,
    ) {
      // Prime pills before the layout for the new text is built, and register for icons
      // that load later. Runs from the TextView constructor too: use nothing initialized after it.
      val contentWidth = width - compoundPaddingLeft - compoundPaddingRight
      if (contentWidth > 0) prepareWidthAwareSpans(text, contentWidth, includeImages = false)
      LinkPillSpan.registerView(text, this)
      super.setText(text, type)
    }

    override fun onMeasure(
      widthMeasureSpec: Int,
      heightMeasureSpec: Int,
    ) {
      if (MeasureSpec.getMode(widthMeasureSpec) != MeasureSpec.UNSPECIFIED) {
        val width = (MeasureSpec.getSize(widthMeasureSpec) - compoundPaddingLeft - compoundPaddingRight).coerceAtLeast(1)
        // TextView keeps its layout when the new width still fits the old lines.
        if (prepareWidthAwareSpans(text, width, includeImages = false) && layout != null) dropTextLayout()
      }
      super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    }

    /**
     * Makes the next measure build a fresh text layout. TextView exposes no direct way:
     * re-setting the text would copy it and clear the selection, while setting the break
     * strategy, even to its current value, discards the layout and nothing else.
     */
    private fun dropTextLayout() {
      breakStrategy = breakStrategy
    }

    override fun dispatchHoverEvent(event: MotionEvent): Boolean =
      accessibilityHelper.dispatchHoverEvent(event) || super.dispatchHoverEvent(event)

    override fun dispatchKeyEvent(event: KeyEvent): Boolean = accessibilityHelper.dispatchKeyEvent(event) || super.dispatchKeyEvent(event)

    override fun requestFocus(
      direction: Int,
      previouslyFocusedRect: Rect?,
    ): Boolean {
      reportingVisibleFocusRect = true
      return try {
        super.requestFocus(direction, previouslyFocusedRect)
      } finally {
        reportingVisibleFocusRect = false
      }
    }

    override fun getDrawingRect(outRect: Rect) {
      super.getDrawingRect(outRect)
      if (!reportingVisibleFocusRect) return
      val visibleOnScreen = Rect()
      if (!getGlobalVisibleRect(visibleOnScreen)) return
      val screenOrigin = IntArray(2)
      getLocationOnScreen(screenOrigin)
      visibleOnScreen.offset(-screenOrigin[0] + scrollX, -screenOrigin[1] + scrollY)
      if (!outRect.intersect(visibleOnScreen)) super.getDrawingRect(outRect)
    }

    override fun onFocusChanged(
      gainFocus: Boolean,
      direction: Int,
      previouslyFocusedRect: Rect?,
    ) {
      super.onFocusChanged(gainFocus, direction, previouslyFocusedRect)
      accessibilityHelper.onFocusChanged(gainFocus, direction, previouslyFocusedRect)
    }

    override fun onDetachedFromWindow() {
      // Before super, and here rather than in a ViewManager's
      // onDropViewInstance: getViewTreeObserver() returns the WINDOW's observer
      // only while the view is attached. Once detached it hands back the view's
      // own floating observer, so a removal then would target the wrong
      // observer and leave the listener on the window.
      accessibilityHelper.cleanup()
      super.onDetachedFromWindow()
    }
  }
