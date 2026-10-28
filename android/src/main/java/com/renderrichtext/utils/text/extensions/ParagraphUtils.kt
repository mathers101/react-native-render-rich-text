package com.renderrichtext.utils.text.extensions

import com.renderrichtext.parser.TiptapASTNode

fun TiptapASTNode.containsBlockImage(): Boolean {
  if (type != TiptapASTNode.NodeType.Paragraph) return false
  val firstChild = children.firstOrNull()
  return firstChild != null && children.size == 1 && firstChild.type == TiptapASTNode.NodeType.Image
}
