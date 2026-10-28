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
        Log.e("TiptapParser", "Failed to load native library", e)
      }
    }

    @JvmStatic
    private external fun nativeParseDocument(document: String): TiptapASTNode?

    val shared: Parser = Parser()
  }

  /**
   * Parses a Tiptap document JSON string. Flag and regex arguments are kept so
   * copied call sites compile; the Tiptap parser ignores them.
   */
  fun parseTiptap(
    tiptap: String,
    flags: Md4cFlags = Md4cFlags.DEFAULT,
    isGFM: Boolean = true,
    linkRegex: LinkRegexConfig? = null,
    inlineCodeLinkRegex: LinkRegexConfig? = null,
  ): TiptapASTNode? {
    if (tiptap.isBlank()) {
      return null
    }
    try {
      return nativeParseDocument(tiptap)
    } catch (e: Exception) {
      Log.e("TiptapParser", "Tiptap parsing failed: ${e.message}", e)
      return null
    }
  }
}
