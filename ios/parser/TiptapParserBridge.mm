#import "ENRMTiptapParser.h"
#include "TiptapParser.hpp"
#import "TiptapASTNode.h"
#include "TiptapASTNode.hpp"
#import <React/RCTLog.h>

// Convert C++ AST node to Objective-C AST node
static TiptapASTNode *convertCppASTToObjC(std::shared_ptr<Tiptap::TiptapASTNode> cppNode)
{
  if (!cppNode) {
    return [[TiptapASTNode alloc] initWithType:TiptapNodeTypeDocument];
  }

  // Convert C++ NodeType enum to Objective-C TiptapNodeType
  TiptapNodeType objcType;
  switch (cppNode->type) {
    case Tiptap::NodeType::Document:
      objcType = TiptapNodeTypeDocument;
      break;
    case Tiptap::NodeType::Paragraph:
      objcType = TiptapNodeTypeParagraph;
      break;
    case Tiptap::NodeType::Text:
      objcType = TiptapNodeTypeText;
      break;
    case Tiptap::NodeType::Link:
      objcType = TiptapNodeTypeLink;
      break;
    case Tiptap::NodeType::Heading:
      objcType = TiptapNodeTypeHeading;
      break;
    case Tiptap::NodeType::LineBreak:
      objcType = TiptapNodeTypeLineBreak;
      break;
    case Tiptap::NodeType::Strong:
      objcType = TiptapNodeTypeStrong;
      break;
    case Tiptap::NodeType::Emphasis:
      objcType = TiptapNodeTypeEmphasis;
      break;
    case Tiptap::NodeType::Strikethrough:
      objcType = TiptapNodeTypeStrikethrough;
      break;
    case Tiptap::NodeType::Underline:
      objcType = TiptapNodeTypeUnderline;
      break;
    case Tiptap::NodeType::Code:
      objcType = TiptapNodeTypeCode;
      break;
    case Tiptap::NodeType::Image:
      objcType = TiptapNodeTypeImage;
      break;
    case Tiptap::NodeType::Blockquote:
      objcType = TiptapNodeTypeBlockquote;
      break;
    case Tiptap::NodeType::UnorderedList:
      objcType = TiptapNodeTypeUnorderedList;
      break;
    case Tiptap::NodeType::OrderedList:
      objcType = TiptapNodeTypeOrderedList;
      break;
    case Tiptap::NodeType::ListItem:
      objcType = TiptapNodeTypeListItem;
      break;
    case Tiptap::NodeType::CodeBlock:
      objcType = TiptapNodeTypeCodeBlock;
      break;
    case Tiptap::NodeType::ThematicBreak:
      objcType = TiptapNodeTypeThematicBreak;
      break;
    case Tiptap::NodeType::Table:
      objcType = TiptapNodeTypeTable;
      break;
    case Tiptap::NodeType::TableHead:
      objcType = TiptapNodeTypeTableHead;
      break;
    case Tiptap::NodeType::TableBody:
      objcType = TiptapNodeTypeTableBody;
      break;
    case Tiptap::NodeType::TableRow:
      objcType = TiptapNodeTypeTableRow;
      break;
    case Tiptap::NodeType::TableHeaderCell:
      objcType = TiptapNodeTypeTableHeaderCell;
      break;
    case Tiptap::NodeType::TableCell:
      objcType = TiptapNodeTypeTableCell;
      break;
    case Tiptap::NodeType::LatexMathInline:
      objcType = TiptapNodeTypeLatexMathInline;
      break;
    case Tiptap::NodeType::LatexMathDisplay:
      objcType = TiptapNodeTypeLatexMathDisplay;
      break;
    case Tiptap::NodeType::Spoiler:
      objcType = TiptapNodeTypeSpoiler;
      break;
    case Tiptap::NodeType::Superscript:
      objcType = TiptapNodeTypeSuperscript;
      break;
    case Tiptap::NodeType::Subscript:
      objcType = TiptapNodeTypeSubscript;
      break;
    case Tiptap::NodeType::Highlight:
      objcType = TiptapNodeTypeHighlight;
      break;
    case Tiptap::NodeType::SoftBreak:
      objcType = TiptapNodeTypeSoftBreak;
      break;
    case Tiptap::NodeType::BlankLine:
      objcType = TiptapNodeTypeBlankLine;
      break;
    case Tiptap::NodeType::Admonition:
      objcType = TiptapNodeTypeAdmonition;
      break;
    case Tiptap::NodeType::Video:
      objcType = TiptapNodeTypeVideo;
      break;
    case Tiptap::NodeType::Factoid:
      objcType = TiptapNodeTypeFactoid;
      break;
  }

  TiptapASTNode *objcNode = [[TiptapASTNode alloc] initWithType:objcType];

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
    TiptapASTNode *objcChild = convertCppASTToObjC(child);
    [objcNode addChild:objcChild];
  }

  return objcNode;
}

TiptapASTNode *parseTiptapWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM,
                                            ENRMLinkRegexConfig *textRegex, ENRMLinkRegexConfig *codeRegex);

TiptapASTNode *parseTiptapWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM)
{
  return parseTiptapWithCppParser(document, flags, isGFM, nil, nil);
}

// Flags and link-regex arguments are ignored. The string is a Tiptap document.
TiptapASTNode *parseTiptapWithCppParser(NSString *document, ENRMMd4cFlags *flags, BOOL isGFM,
                                            ENRMLinkRegexConfig *textRegex, ENRMLinkRegexConfig *codeRegex)
{
  (void)flags;
  (void)isGFM;
  (void)textRegex;
  (void)codeRegex;

  if (document.length == 0) {
    return [[TiptapASTNode alloc] initWithType:TiptapNodeTypeDocument];
  }

  const char *utf8String = [document UTF8String];
  if (!utf8String) {
    RCTLogError(@"TiptapParserBridge: Failed to convert document to UTF-8");
    return [[TiptapASTNode alloc] initWithType:TiptapNodeTypeDocument];
  }

  auto cppAST = Tiptap::parseTiptapDocument(std::string(utf8String));
  return convertCppASTToObjC(cppAST);
}
