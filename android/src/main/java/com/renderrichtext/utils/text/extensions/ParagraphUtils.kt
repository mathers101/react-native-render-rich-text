package com.renderrichtext.utils.text.extensions

import com.renderrichtext.parser.MarkdownASTNode

fun MarkdownASTNode.containsBlockImage(): Boolean {
  if (type != MarkdownASTNode.NodeType.Paragraph) return false
  val firstChild = children.firstOrNull()
  return firstChild != null && children.size == 1 && firstChild.type == MarkdownASTNode.NodeType.Image
}
