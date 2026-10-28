package com.renderrichtext.parser

data class TiptapASTNode(
  val type: NodeType,
  val content: String = "",
  val attributes: Map<String, String> = emptyMap(),
  val children: List<TiptapASTNode> = emptyList(),
) {
  enum class NodeType {
    Document,
    Paragraph,
    Text,
    Link,
    Heading,
    LineBreak,
    Strong,
    Emphasis,
    Strikethrough,
    Underline,
    Code,
    Image,
    Blockquote,
    UnorderedList,
    OrderedList,
    ListItem,
    CodeBlock,
    ThematicBreak,
    Table,
    TableHead,
    TableBody,
    TableRow,
    TableHeaderCell,
    TableCell,
    LatexMathInline,
    LatexMathDisplay,
    Spoiler,
    Superscript,
    Subscript,
    Highlight,
    SoftBreak,
    BlankLine,
    Admonition,
    Video,
    Factoid,
  }

  fun getAttribute(key: String): String? = attributes[key]
}

// A node type that md4c emits as a standalone block stacked vertically, as opposed to an inline span.
internal fun TiptapASTNode.NodeType.isTopLevelBlock(): Boolean =
  when (this) {
    TiptapASTNode.NodeType.Paragraph,
    TiptapASTNode.NodeType.Heading,
    TiptapASTNode.NodeType.Blockquote,
    TiptapASTNode.NodeType.Admonition,
    TiptapASTNode.NodeType.UnorderedList,
    TiptapASTNode.NodeType.OrderedList,
    TiptapASTNode.NodeType.CodeBlock,
    TiptapASTNode.NodeType.ThematicBreak,
    TiptapASTNode.NodeType.BlankLine,
    TiptapASTNode.NodeType.Table,
    TiptapASTNode.NodeType.LatexMathDisplay,
    TiptapASTNode.NodeType.Video,
    -> true

    else -> false
  }
