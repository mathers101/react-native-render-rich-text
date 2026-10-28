package com.renderrichtext

import android.content.Context
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ReactStylesDiffMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.StateWrapper
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.EnrichedTiptapTextManagerDelegate
import com.facebook.react.viewmanagers.EnrichedTiptapTextManagerInterface
import com.facebook.yoga.YogaMeasureMode
import com.renderrichtext.spoiler.SpoilerOverlay
import com.renderrichtext.utils.common.applyReactBorderProps
import com.renderrichtext.utils.common.emitContextMenuItemPress
import com.renderrichtext.utils.common.emitFactoidPress
import com.renderrichtext.utils.common.emitLatexError
import com.renderrichtext.utils.common.emitLinkLongPress
import com.renderrichtext.utils.common.emitLinkPress
import com.renderrichtext.utils.common.emitTaskListItemPress
import com.renderrichtext.utils.common.tiptapEventTypeConstants
import com.renderrichtext.utils.common.parseAccessibilityLabels
import com.renderrichtext.utils.common.parseContextMenuItems
import com.renderrichtext.utils.common.parseImageRequestHeaders
import com.renderrichtext.utils.common.parseLinkPillContent
import com.renderrichtext.utils.common.parseLinkRecognition
import com.renderrichtext.utils.common.parseMd4cFlags
import com.renderrichtext.utils.common.parseSelectionMenuConfig
import com.renderrichtext.utils.text.interaction.TaskListTapUtils
import com.renderrichtext.utils.text.interaction.TaskListToggleUtils

@ReactModule(name = EnrichedTiptapTextManager.NAME)
class EnrichedTiptapTextManager :
  SimpleViewManager<EnrichedTiptapText>(),
  EnrichedTiptapTextManagerInterface<EnrichedTiptapText> {
  private val mDelegate: ViewManagerDelegate<EnrichedTiptapText> = EnrichedTiptapTextManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<EnrichedTiptapText>? = mDelegate

  override fun getName(): String = NAME

  override fun createViewInstance(reactContext: ThemedReactContext): EnrichedTiptapText {
    val view = EnrichedTiptapText(reactContext)
    view.onContextMenuItemPressCallback = { itemText, selectedText, selectionStart, selectionEnd ->
      emitContextMenuItemPress(view, itemText, selectedText, selectionStart, selectionEnd)
    }

    view.setOnLinkPressCallback { url ->
      emitLinkPress(view, url)
    }

    view.setOnFactoidPressCallback { factoidId ->
      emitFactoidPress(view, factoidId)
    }

    view.setOnLinkLongPressCallback { url ->
      emitLinkLongPress(view, url)
    }

    view.setOnTaskListItemPressCallback { taskIndex, checked, itemText ->
      val newChecked = !checked

      val styleConfig = view.tiptapStyle
      val optimizedSuccess =
        styleConfig != null && TaskListTapUtils.updateTaskListItemCheckedState(view, taskIndex, newChecked, styleConfig)

      if (optimizedSuccess) {
        emitTaskListItemPress(view, taskIndex, newChecked, itemText)
        return@setOnTaskListItemPressCallback
      }

      val currentTiptap = view.currentTiptap
      val updatedTiptap = TaskListToggleUtils.toggleAtIndex(currentTiptap, taskIndex, newChecked)
      view.setTiptapContent(updatedTiptap)

      emitTaskListItemPress(view, taskIndex, newChecked, itemText)
    }

    view.setOnLatexErrorCallback { source, message, displayMode ->
      emitLatexError(view, source, message, displayMode)
    }
    return view
  }

  override fun onAfterUpdateTransaction(view: EnrichedTiptapText) {
    super.onAfterUpdateTransaction(view)
    view.commitProps()
  }

  // Replay containerStyle border props the delegate drops (see applyReactBorderProps).
  override fun updateProperties(
    view: EnrichedTiptapText,
    props: ReactStylesDiffMap,
  ) {
    super.updateProperties(view, props)
    applyReactBorderProps(view, props)
  }

  override fun updateState(
    view: EnrichedTiptapText,
    props: ReactStylesDiffMap?,
    stateWrapper: StateWrapper?,
  ): Any? {
    view.stateWrapper = stateWrapper
    return super.updateState(view, props, stateWrapper)
  }

  override fun onDropViewInstance(view: EnrichedTiptapText) {
    super.onDropViewInstance(view)
    view.cleanup()
    MeasurementStore.clearFontScalingSettings(view.id)
    MeasurementStore.clearBreakStrategy(view.id)
    view.layoutManager.releaseMeasurementStore()
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> = tiptapEventTypeConstants()

  @ReactProp(name = "document")
  override fun setDocument(
    view: EnrichedTiptapText?,
    document: String?,
  ) {
    view?.setTiptapContent(document ?: "")
  }

  @ReactProp(name = "tiptapStyle")
  override fun setTiptapStyle(
    view: EnrichedTiptapText?,
    style: ReadableMap?,
  ) {
    view?.setTiptapStyle(style)
  }

  @ReactProp(name = "selectable", defaultBoolean = true)
  override fun setSelectable(
    view: EnrichedTiptapText?,
    selectable: Boolean,
  ) {
    view?.setIsSelectable(selectable)
  }

  override fun setSelectionColor(
    view: EnrichedTiptapText?,
    value: Int?,
  ) {
    view?.setSelectionColor(value)
  }

  override fun setSelectionHandleColor(
    view: EnrichedTiptapText?,
    value: Int?,
  ) {
    view?.setSelectionHandleColor(value)
  }

  @ReactProp(name = "linkRecognition")
  override fun setLinkRecognition(
    view: EnrichedTiptapText?,
    value: ReadableMap?,
  ) {
    val recognition = parseLinkRecognition(value)
    view?.setLinkRegex(recognition.text)
    view?.setInlineCodeLinkRegex(recognition.inlineCode)
  }

  @ReactProp(name = "md4cFlags")
  override fun setMd4cFlags(
    view: EnrichedTiptapText?,
    flags: ReadableMap?,
  ) {
    view?.setMd4cFlags(parseMd4cFlags(flags))
  }

  @ReactProp(name = "isGFM", defaultBoolean = false)
  override fun setIsGFM(
    view: EnrichedTiptapText?,
    isGFM: Boolean,
  ) {
    view?.setIsGFM(isGFM)
  }

  @ReactProp(name = "allowFontScaling", defaultBoolean = true)
  override fun setAllowFontScaling(
    view: EnrichedTiptapText?,
    allowFontScaling: Boolean,
  ) {
    view?.setAllowFontScaling(allowFontScaling)
  }

  @ReactProp(name = "maxFontSizeMultiplier", defaultFloat = 0f)
  override fun setMaxFontSizeMultiplier(
    view: EnrichedTiptapText?,
    maxFontSizeMultiplier: Float,
  ) {
    view?.setMaxFontSizeMultiplier(maxFontSizeMultiplier)
  }

  @ReactProp(name = "allowTrailingMargin", defaultBoolean = false)
  override fun setAllowTrailingMargin(
    view: EnrichedTiptapText?,
    allowTrailingMargin: Boolean,
  ) {
    view?.setAllowTrailingMargin(allowTrailingMargin)
  }

  @ReactProp(name = "enableLinkPreview", defaultBoolean = true)
  override fun setEnableLinkPreview(
    view: EnrichedTiptapText?,
    enableLinkPreview: Boolean,
  ) {
    // No-op on Android — only used on iOS
  }

  @ReactProp(name = "enableTaskListItemToggle", defaultBoolean = true)
  override fun setEnableTaskListItemToggle(
    view: EnrichedTiptapText?,
    enableTaskListItemToggle: Boolean,
  ) {
    view?.setEnableTaskListItemToggle(enableTaskListItemToggle)
  }

  @ReactProp(name = "enableImagePress", defaultBoolean = false)
  override fun setEnableImagePress(
    view: EnrichedTiptapText?,
    enableImagePress: Boolean,
  ) {
    view?.setEnableImagePress(enableImagePress)
  }

  @ReactProp(name = "enableBlockContextMenu", defaultBoolean = true)
  override fun setEnableBlockContextMenu(
    view: EnrichedTiptapText?,
    enableBlockContextMenu: Boolean,
  ) {
    // No-op: block context menus are rendered by the container component.
  }

  @ReactProp(name = "enableCodeBlockPress", defaultBoolean = false)
  override fun setEnableCodeBlockPress(
    view: EnrichedTiptapText?,
    enableCodeBlockPress: Boolean,
  ) {
    view?.setEnableCodeBlockPress(enableCodeBlockPress)
  }

  @ReactProp(name = "lineBreakStrategyIOS")
  override fun setLineBreakStrategyIOS(
    view: EnrichedTiptapText?,
    strategy: String?,
  ) {
    // No-op on Android — only used on iOS
  }

  @ReactProp(name = "writingDirection")
  override fun setWritingDirection(
    view: EnrichedTiptapText?,
    value: String?,
  ) {
    // No-op on Android — first-strong per-paragraph resolution is the platform default
  }

  @ReactProp(name = "streamingAnimation", defaultBoolean = false)
  override fun setStreamingAnimation(
    view: EnrichedTiptapText?,
    streamingAnimation: Boolean,
  ) {
    view?.setStreamingAnimation(streamingAnimation)
  }

  @ReactProp(name = "streamingConfig")
  override fun setStreamingConfig(
    view: EnrichedTiptapText?,
    config: ReadableMap?,
  ) {
    // No-op — CommonMark mode uses a single text view; table streaming is GFM-only.
  }

  @ReactProp(name = "spoilerOverlay")
  override fun setSpoilerOverlay(
    view: EnrichedTiptapText?,
    mode: String?,
  ) {
    view?.spoilerOverlay = SpoilerOverlay.fromString(mode)
  }

  @ReactProp(name = "textBreakStrategy")
  override fun setTextBreakStrategy(
    view: EnrichedTiptapText?,
    strategy: String?,
  ) {
    view?.setTextBreakStrategy(strategy ?: "highQuality")
  }

  @ReactProp(name = "numberOfLines", defaultInt = 0)
  override fun setNumberOfLines(
    view: EnrichedTiptapText?,
    value: Int,
  ) {
    view?.setTiptapNumberOfLines(value)
  }

  @ReactProp(name = "ellipsizeMode")
  override fun setEllipsizeMode(
    view: EnrichedTiptapText?,
    value: String?,
  ) {
    view?.setTiptapEllipsizeMode(value ?: "tail")
  }

  @ReactProp(name = "linkContextMenuItems")
  override fun setLinkContextMenuItems(
    view: EnrichedTiptapText?,
    value: ReadableArray?,
  ) {
    // Link menus are iOS-only for now; onLinkLongPress is the Android hook.
  }

  @ReactProp(name = "contextMenuItems")
  override fun setContextMenuItems(
    view: EnrichedTiptapText?,
    value: ReadableArray?,
  ) {
    if (view == null) return
    view.setContextMenuItems(parseContextMenuItems(value))
  }

  @ReactProp(name = "imageRequestHeaders")
  override fun setImageRequestHeaders(
    view: EnrichedTiptapText?,
    value: ReadableArray?,
  ) {
    if (view == null) return
    view.setImageRequestHeaders(parseImageRequestHeaders(value))
  }

  @ReactProp(name = "linkPillContent")
  override fun setLinkPillContent(
    view: EnrichedTiptapText?,
    value: ReadableArray?,
  ) {
    if (view == null) return
    view.setLinkPillContent(parseLinkPillContent(value))
  }

  @ReactProp(name = "selectionMenuConfig")
  override fun setSelectionMenuConfig(
    view: EnrichedTiptapText?,
    value: ReadableMap?,
  ) {
    if (view == null) return
    view.setSelectionMenuConfig(parseSelectionMenuConfig(value))
  }

  @ReactProp(name = "accessibilityLabels")
  override fun setAccessibilityLabels(
    view: EnrichedTiptapText?,
    value: ReadableMap?,
  ) {
    if (view == null) return
    view.setAccessibilityLabels(parseAccessibilityLabels(value))
  }

  override fun setPadding(
    view: EnrichedTiptapText,
    left: Int,
    top: Int,
    right: Int,
    bottom: Int,
  ) {
    super.setPadding(view, left, top, right, bottom)
    view.setPadding(left, top, right, bottom)
  }

  override fun measure(
    context: Context,
    localData: ReadableMap?,
    props: ReadableMap?,
    state: ReadableMap?,
    width: Float,
    widthMode: YogaMeasureMode?,
    height: Float,
    heightMode: YogaMeasureMode?,
    attachmentsPositions: FloatArray?,
  ): Long {
    val id = localData?.getInt("viewTag")
    return MeasurementStore.getMeasureById(context, id, width, widthMode, height, heightMode, props)
  }

  companion object {
    const val NAME = "EnrichedTiptapText"
  }
}
