package com.renderrichtext.utils.common

import com.renderrichtext.parser.TiptapASTNode

/**
 * Shared code block node semantics, used by both tiptap flavors so the
 * meaning of a CodeBlock AST node (its text, language, fence) is defined in
 * one place. Language display names come from the shared C++ core
 * (cpp/highlight/CodeBlockLanguages.hpp) so all platforms label fences
 * identically; when the native library is unavailable the raw fence string
 * is shown instead.
 */
object CodeBlockNode {
  fun extractCode(node: TiptapASTNode): String {
    val builder = StringBuilder()

    fun append(current: TiptapASTNode) {
      builder.append(current.content)
      current.children.forEach { append(it) }
    }
    append(node)
    return builder.toString().trimEnd('\n')
  }

  fun language(node: TiptapASTNode): String? = node.getAttribute("language")?.takeIf { it.isNotEmpty() }

  fun fenceChar(node: TiptapASTNode): String = node.getAttribute("fenceChar")?.takeIf { it.isNotEmpty() } ?: "`"

  fun fencedTiptap(
    code: String,
    language: String?,
    fenceChar: String,
  ): String {
    val fence = fenceChar.repeat(3)
    return "$fence${language.orEmpty()}\n$code\n$fence"
  }

  fun displayLanguageName(language: String?): String {
    if (language.isNullOrEmpty()) return ""
    return language
  }
}
