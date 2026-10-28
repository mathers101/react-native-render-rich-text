package com.renderrichtext.utils.common

import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.UIManagerHelper
import com.renderrichtext.accessibility.AccessibilityLabels
import com.renderrichtext.events.CodeBlockPressEvent
import com.renderrichtext.events.FactoidPressEvent
import com.renderrichtext.events.ContextMenuItemPressEvent
import com.renderrichtext.events.CopyPressEvent
import com.renderrichtext.events.LatexErrorEvent
import com.renderrichtext.events.LinkLongPressEvent
import com.renderrichtext.events.LinkPressEvent
import com.renderrichtext.events.TaskListItemPressEvent
import com.renderrichtext.parser.Md4cFlags
import com.renderrichtext.styles.LinkPillContent
import com.renderrichtext.utils.text.view.SelectionMenuConfig

fun tiptapEventTypeConstants(): MutableMap<String, Any> {
  val map = mutableMapOf<String, Any>()
  map[LinkPressEvent.EVENT_NAME] = mapOf("registrationName" to LinkPressEvent.EVENT_NAME)
  map[FactoidPressEvent.EVENT_NAME] = mapOf("registrationName" to FactoidPressEvent.EVENT_NAME)
  map[LinkLongPressEvent.EVENT_NAME] =
    mapOf("registrationName" to LinkLongPressEvent.EVENT_NAME)
  map[TaskListItemPressEvent.EVENT_NAME] =
    mapOf("registrationName" to TaskListItemPressEvent.EVENT_NAME)
  map[CopyPressEvent.EVENT_NAME] =
    mapOf("registrationName" to CopyPressEvent.EVENT_NAME)
  map[CodeBlockPressEvent.EVENT_NAME] =
    mapOf("registrationName" to CodeBlockPressEvent.EVENT_NAME)
  map[ContextMenuItemPressEvent.EVENT_NAME] =
    mapOf("registrationName" to ContextMenuItemPressEvent.EVENT_NAME)
  map[LatexErrorEvent.EVENT_NAME] =
    mapOf("registrationName" to LatexErrorEvent.EVENT_NAME)
  return map
}

fun emitFactoidPress(
  view: View,
  factoidId: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(FactoidPressEvent(surfaceId, view.id, factoidId))
}

fun emitLinkPress(
  view: View,
  url: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(LinkPressEvent(surfaceId, view.id, url))
}

fun emitLinkLongPress(
  view: View,
  url: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(LinkLongPressEvent(surfaceId, view.id, url))
}

fun emitTaskListItemPress(
  view: View,
  taskIndex: Int,
  checked: Boolean,
  itemText: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(
    TaskListItemPressEvent(surfaceId, view.id, taskIndex, checked, itemText),
  )
}

fun emitCopyPress(
  view: View,
  code: String,
  language: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(
    CopyPressEvent(surfaceId, view.id, code, language),
  )
}

fun emitLatexError(
  view: View,
  source: String,
  message: String?,
  displayMode: Boolean,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(
    LatexErrorEvent(surfaceId, view.id, source, message, displayMode),
  )
}

fun emitCodeBlockPress(
  view: View,
  code: String,
  language: String,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(
    CodeBlockPressEvent(surfaceId, view.id, code, language),
  )
}

fun emitContextMenuItemPress(
  view: View,
  itemText: String,
  selectedText: String,
  selectionStart: Int,
  selectionEnd: Int,
) {
  val context = view.context as com.facebook.react.bridge.ReactContext
  val surfaceId = UIManagerHelper.getSurfaceId(context)
  val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
  eventDispatcher?.dispatchEvent(
    ContextMenuItemPressEvent(
      surfaceId,
      view.id,
      itemText,
      selectedText,
      selectionStart,
      selectionEnd,
    ),
  )
}

fun parseMd4cFlags(flags: ReadableMap?): Md4cFlags =
  Md4cFlags(
    underline = flags?.getBoolean("underline") ?: false,
    latexMath = FeatureFlags.IS_MATH_ENABLED && (flags?.getBoolean("latexMath") ?: true),
    superscript = flags?.getBoolean("superscript") ?: false,
    subscript = flags?.getBoolean("subscript") ?: false,
    highlight = flags?.getBoolean("highlight") ?: false,
    hardSoftBreaks = flags?.getBoolean("hardSoftBreaks") ?: false,
    preserveBlankLines = flags?.getBoolean("preserveBlankLines") ?: false,
    admonitions = flags?.getBoolean("admonitions") ?: true,
  )

fun parseContextMenuItems(value: ReadableArray?): List<String> =
  (0 until (value?.size() ?: 0)).mapNotNull { value?.getMap(it)?.getString("text") }

fun parseImageRequestHeaders(value: ReadableArray?): Map<String, String> =
  (0 until (value?.size() ?: 0))
    .mapNotNull { index ->
      val header = value?.getMap(index) ?: return@mapNotNull null
      val name = header.getString("name") ?: return@mapNotNull null
      val headerValue = header.getString("value") ?: return@mapNotNull null
      name to headerValue
    }.toMap()

fun parseLinkPillContent(value: ReadableArray?): Map<String, LinkPillContent> =
  (0 until (value?.size() ?: 0))
    .mapNotNull { index ->
      val entry = value?.getMap(index) ?: return@mapNotNull null
      val url = entry.getString("url") ?: return@mapNotNull null
      url to LinkPillContent.fromReadableMap(entry)
    }.toMap()

fun parseSelectionMenuConfig(value: ReadableMap?): SelectionMenuConfig {
  if (value == null) return SelectionMenuConfig()
  return SelectionMenuConfig(
    copyAsTiptap = value.getBoolean("copyAsTiptap"),
    copyImageUrl = value.getBoolean("copyImageUrl"),
    copyLabel = value.getString("copyLabel") ?: "",
    copyAsTiptapLabel = value.getString("copyAsTiptapLabel") ?: "",
    copyImageUrlLabel = value.getString("copyImageUrlLabel") ?: "",
    copyImageUrlsLabel = value.getString("copyImageUrlsLabel") ?: "",
    copyImageUrlPluralTemplates = parseStringList(value.getArray("copyImageUrlPluralTemplates")),
  )
}

fun parseAccessibilityLabels(value: ReadableMap?): AccessibilityLabels {
  if (value == null) return AccessibilityLabels()
  val list = value.getMap("list")
  val blockquote = value.getMap("blockquote")
  val table = value.getMap("table")
  val math = value.getMap("math")
  val codeBlock = value.getMap("codeBlock")
  val rotor = value.getMap("rotor")
  return AccessibilityLabels(
    bulletPoint = list?.getString("bulletPoint") ?: "",
    nestedBulletPoint = list?.getString("nestedBulletPoint") ?: "",
    orderedItem = list?.getString("orderedItem") ?: "",
    nestedOrderedItem = list?.getString("nestedOrderedItem") ?: "",
    blockquote = blockquote?.getString("quote") ?: "",
    nestedBlockquote = blockquote?.getString("nestedQuote") ?: "",
    tableRow = table?.getString("row") ?: "",
    mathEquation = math?.getString("equation") ?: "",
    codeBlockWrap = codeBlock?.getString("wrap") ?: "",
    codeBlockUnwrap = codeBlock?.getString("unwrap") ?: "",
    rotorHeadings = rotor?.getString("headings") ?: "",
    rotorLinks = rotor?.getString("links") ?: "",
    rotorImages = rotor?.getString("images") ?: "",
  )
}

private fun parseStringList(value: ReadableArray?): List<String> = (0 until (value?.size() ?: 0)).mapNotNull { value?.getString(it) }
