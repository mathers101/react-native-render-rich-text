#import "ENRMMarkdownParser.h"
#include "TipTapParser.hpp"
#import "MarkdownASTNode.h"
#include "MarkdownASTNode.hpp"
#import <React/RCTLog.h>

// Convert C++ AST node to Objective-C AST node
static MarkdownASTNode *convertCppASTToObjC(std::shared_ptr<Markdown::MarkdownASTNode> cppNode)
{
  if (!cppNode) {
    return [[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeDocument];
  }

  // Convert C++ NodeType enum to Objective-C MarkdownNodeType
  MarkdownNodeType objcType;
  switch (cppNode->type) {
    case Markdown::NodeType::Document:
      objcType = MarkdownNodeTypeDocument;
      break;
    case Markdown::NodeType::Paragraph:
      objcType = MarkdownNodeTypeParagraph;
      break;
    case Markdown::NodeType::Text:
      objcType = MarkdownNodeTypeText;
      break;
    case Markdown::NodeType::Link:
      objcType = MarkdownNodeTypeLink;
      break;
    case Markdown::NodeType::Heading:
      objcType = MarkdownNodeTypeHeading;
      break;
    case Markdown::NodeType::LineBreak:
      objcType = MarkdownNodeTypeLineBreak;
      break;
    case Markdown::NodeType::Strong:
      objcType = MarkdownNodeTypeStrong;
      break;
    case Markdown::NodeType::Emphasis:
      objcType = MarkdownNodeTypeEmphasis;
      break;
    case Markdown::NodeType::Strikethrough:
      objcType = MarkdownNodeTypeStrikethrough;
      break;
    case Markdown::NodeType::Underline:
      objcType = MarkdownNodeTypeUnderline;
      break;
    case Markdown::NodeType::Code:
      objcType = MarkdownNodeTypeCode;
      break;
    case Markdown::NodeType::Image:
      objcType = MarkdownNodeTypeImage;
      break;
    case Markdown::NodeType::Blockquote:
      objcType = MarkdownNodeTypeBlockquote;
      break;
    case Markdown::NodeType::UnorderedList:
      objcType = MarkdownNodeTypeUnorderedList;
      break;
    case Markdown::NodeType::OrderedList:
      objcType = MarkdownNodeTypeOrderedList;
      break;
    case Markdown::NodeType::ListItem:
      objcType = MarkdownNodeTypeListItem;
      break;
    case Markdown::NodeType::CodeBlock:
      objcType = MarkdownNodeTypeCodeBlock;
      break;
    case Markdown::NodeType::ThematicBreak:
      objcType = MarkdownNodeTypeThematicBreak;
      break;
    case Markdown::NodeType::Table:
      objcType = MarkdownNodeTypeTable;
      break;
    case Markdown::NodeType::TableHead:
      objcType = MarkdownNodeTypeTableHead;
      break;
    case Markdown::NodeType::TableBody:
      objcType = MarkdownNodeTypeTableBody;
      break;
    case Markdown::NodeType::TableRow:
      objcType = MarkdownNodeTypeTableRow;
      break;
    case Markdown::NodeType::TableHeaderCell:
      objcType = MarkdownNodeTypeTableHeaderCell;
      break;
    case Markdown::NodeType::TableCell:
      objcType = MarkdownNodeTypeTableCell;
      break;
    case Markdown::NodeType::LatexMathInline:
      objcType = MarkdownNodeTypeLatexMathInline;
      break;
    case Markdown::NodeType::LatexMathDisplay:
      objcType = MarkdownNodeTypeLatexMathDisplay;
      break;
    case Markdown::NodeType::Spoiler:
      objcType = MarkdownNodeTypeSpoiler;
      break;
    case Markdown::NodeType::Superscript:
      objcType = MarkdownNodeTypeSuperscript;
      break;
    case Markdown::NodeType::Subscript:
      objcType = MarkdownNodeTypeSubscript;
      break;
    case Markdown::NodeType::Highlight:
      objcType = MarkdownNodeTypeHighlight;
      break;
    case Markdown::NodeType::SoftBreak:
      objcType = MarkdownNodeTypeSoftBreak;
      break;
    case Markdown::NodeType::BlankLine:
      objcType = MarkdownNodeTypeBlankLine;
      break;
    case Markdown::NodeType::Admonition:
      objcType = MarkdownNodeTypeAdmonition;
      break;
    case Markdown::NodeType::Video:
      objcType = MarkdownNodeTypeVideo;
      break;
    case Markdown::NodeType::Factoid:
      objcType = MarkdownNodeTypeFactoid;
      break;
  }

  MarkdownASTNode *objcNode = [[MarkdownASTNode alloc] initWithType:objcType];

  // Convert content
  if (!cppNode->content.empty()) {
    objcNode.content = [NSString stringWithUTF8String:cppNode->content.c_str()];
  }

  // Convert attributes
  for (const auto &[key, value] : cppNode->attributes) {
    NSString *objcKey = [NSString stringWithUTF8String:key.c_str()];
    NSString *objcValue = [NSString stringWithUTF8String:value.c_str()];
    [objcNode setAttribute:objcKey value:objcValue];
  }

  // Convert children recursively
  for (const auto &child : cppNode->children) {
    MarkdownASTNode *objcChild = convertCppASTToObjC(child);
    [objcNode addChild:objcChild];
  }

  return objcNode;
}

MarkdownASTNode *parseMarkdownWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM,
                                            ENRMLinkRegexConfig *textRegex, ENRMLinkRegexConfig *codeRegex);

MarkdownASTNode *parseMarkdownWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM)
{
  return parseMarkdownWithCppParser(document, flags, isGFM, nil, nil);
}

// Flags and link-regex arguments are ignored. The string is a TipTap document.
MarkdownASTNode *parseMarkdownWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM,
                                            ENRMLinkRegexConfig *textRegex, ENRMLinkRegexConfig *codeRegex)
{
  (void)flags;
  (void)isGFM;
  (void)textRegex;
  (void)codeRegex;

  if (document.length == 0) {
    return [[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeDocument];
  }

  const char *utf8String = [document UTF8String];
  if (!utf8String) {
    RCTLogError(@"MarkdownParserBridge: Failed to convert document to UTF-8");
    return [[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeDocument];
  }

  auto cppAST = Markdown::parseTipTapDocument(std::string(utf8String));
  return convertCppASTToObjC(cppAST);
}
