package com.renderrichtext.parser

import android.util.Log
import com.renderrichtext.utils.common.LinkRegexConfig

data class Md4cFlags(
  val underline: Boolean = false,
  val latexMath: Boolean = false,
  val superscript: Boolean = false,
  val subscript: Boolean = false,
  val highlight: Boolean = false,
  val permissiveAutolinks: Boolean = true,
  val hardSoftBreaks: Boolean = false,
  val preserveBlankLines: Boolean = false,
  val admonitions: Boolean = false,
) {
  companion object {
    val DEFAULT = Md4cFlags()
  }
}

class Parser {
  companion object {
    init {
      try {
        System.loadLibrary("react_codegen_RichTextSpec")
      } catch (e: UnsatisfiedLinkError) {
        Log.e("MarkdownParser", "Failed to load native library", e)
      }
    }

    @JvmStatic
    private external fun nativeParseDocument(document: String): MarkdownASTNode?

    val shared: Parser = Parser()
  }

  /**
   * Parses a TipTap document JSON string. Flag and regex arguments are kept so
   * copied call sites compile; the TipTap parser ignores them.
   */
  fun parseMarkdown(
    markdown: String,
    flags: Md4cFlags = Md4cFlags.DEFAULT,
    isGFM: Boolean = true,
    linkRegex: LinkRegexConfig? = null,
    inlineCodeLinkRegex: LinkRegexConfig? = null,
  ): MarkdownASTNode? {
    if (markdown.isBlank()) {
      return null
    }
    try {
      return nativeParseDocument(markdown)
    } catch (e: Exception) {
      Log.e("MarkdownParser", "TipTap parsing failed: ${e.message}", e)
      return null
    }
  }
}
