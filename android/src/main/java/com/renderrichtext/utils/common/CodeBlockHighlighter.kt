package com.renderrichtext.utils.common

import android.text.Spannable
import com.renderrichtext.styles.CodeBlockStyle

/**
 * Syntax highlighting is not part of this library. Code blocks stay plain
 * monospace; the language attribute is kept on the node and not colored.
 */
enum class HighlightTokenType {
  Keyword,
  Operator,
  Punctuation,
  String,
  Number,
  Constant,
  Comment,
  Function,
  Type,
  Variable,
  Property,
  Tag,
  Attribute,
  Embedded,
}

object CodeBlockHighlighter {
  fun highlight(
    target: Spannable,
    code: String,
    language: String?,
    style: CodeBlockStyle,
    offset: Int = 0,
  ) {
  }
}
