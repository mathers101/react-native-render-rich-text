#include "TipTapParser.hpp"

#include <algorithm>
#include <iostream>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

using Markdown::MarkdownASTNode;
using Markdown::NodeType;
using Markdown::parseTipTapDocument;

namespace {

int g_failed = 0;

const char *typeName(NodeType type) {
  switch (type) {
    case NodeType::Document:
      return "Document";
    case NodeType::Paragraph:
      return "Paragraph";
    case NodeType::Text:
      return "Text";
    case NodeType::Link:
      return "Link";
    case NodeType::Heading:
      return "Heading";
    case NodeType::LineBreak:
      return "LineBreak";
    case NodeType::Strong:
      return "Strong";
    case NodeType::Emphasis:
      return "Emphasis";
    case NodeType::Strikethrough:
      return "Strikethrough";
    case NodeType::Underline:
      return "Underline";
    case NodeType::Code:
      return "Code";
    case NodeType::Image:
      return "Image";
    case NodeType::Blockquote:
      return "Blockquote";
    case NodeType::UnorderedList:
      return "UnorderedList";
    case NodeType::OrderedList:
      return "OrderedList";
    case NodeType::ListItem:
      return "ListItem";
    case NodeType::CodeBlock:
      return "CodeBlock";
    case NodeType::ThematicBreak:
      return "ThematicBreak";
    case NodeType::Highlight:
      return "Highlight";
    case NodeType::Factoid:
      return "Factoid";
    default:
      return "Other";
  }
}

void dump(const MarkdownASTNode &node, std::ostream &out, int indent) {
  out << std::string(static_cast<size_t>(indent) * 2, ' ') << typeName(node.type);
  if (!node.content.empty()) {
    out << " \"" << node.content << "\"";
  }
  std::vector<std::pair<std::string, std::string>> attributes(node.attributes.begin(), node.attributes.end());
  std::sort(attributes.begin(), attributes.end());
  for (const auto &entry : attributes) {
    out << " " << entry.first << "=" << entry.second;
  }
  out << "\n";
  for (const auto &child : node.children) {
    dump(*child, out, indent + 1);
  }
}

std::string dump(const MarkdownASTNode &node) {
  std::ostringstream out;
  dump(node, out, 0);
  return out.str();
}

void expect(const std::string &name, const std::string &actual, const std::string &expected) {
  if (actual == expected) {
    std::cout << "ok  " << name << "\n";
    return;
  }
  std::cout << "FAIL " << name << "\n--- actual ---\n" << actual << "--- expected ---\n" << expected << "\n";
  g_failed++;
}

} // namespace

int main() {
  {
    auto ast = parseTipTapDocument(R"({
      "type": "doc",
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "styled",
          "marks": [
            {"type": "bold"},
            {"type": "italic"},
            {"type": "strike"},
            {"type": "code"},
            {"type": "underline"},
            {"type": "highlight"},
            {"type": "link", "attrs": {"href": "https://example.com"}}
          ]
        }]
      }]
    })");
    expect("mark nesting", dump(*ast),
           "Document\n"
           "  Paragraph\n"
           "    Link url=https://example.com\n"
           "      Highlight\n"
           "        Underline\n"
           "          Strikethrough\n"
           "            Emphasis\n"
           "              Strong\n"
           "                Code\n"
           "                  Text \"styled\"\n");
  }

  {
    auto ast = parseTipTapDocument(R"({
      "type": "doc",
      "content": [
        {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Title"}]},
        {"type": "bulletList", "content": [
          {"type": "listItem", "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "One"}]}
          ]}
        ]},
        {"type": "orderedList", "attrs": {"start": 4}, "content": [
          {"type": "listItem", "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Four"}]}
          ]}
        ]},
        {"type": "blockquote", "content": [
          {"type": "paragraph", "content": [
            {"type": "text", "text": "Quote"},
            {"type": "hardBreak"},
            {"type": "text", "text": "next"}
          ]}
        ]},
        {"type": "codeBlock", "attrs": {"language": "ts"}, "content": [
          {"type": "text", "text": "const n = 1"}
        ]},
        {"type": "horizontalRule"}
      ]
    })");
    expect("blocks", dump(*ast),
           "Document\n"
           "  Heading level=3\n"
           "    Text \"Title\"\n"
           "  UnorderedList\n"
           "    ListItem\n"
           "      Paragraph\n"
           "        Text \"One\"\n"
           "  OrderedList start=4\n"
           "    ListItem\n"
           "      Paragraph\n"
           "        Text \"Four\"\n"
           "  Blockquote\n"
           "    Paragraph\n"
           "      Text \"Quote\"\n"
           "      LineBreak\n"
           "      Text \"next\"\n"
           "  CodeBlock language=ts\n"
           "    Text \"const n = 1\"\n"
           "  ThematicBreak\n");
  }

  {
    auto ast = parseTipTapDocument(R"({"type":"doc"})");
    expect("empty document", dump(*ast), "Document\n");
  }

  {
    auto ast = parseTipTapDocument(R"({"type":"doc","content":[]})");
    expect("empty content", dump(*ast), "Document\n");
  }

  {
    auto ast = parseTipTapDocument("not json");
    expect("invalid json", dump(*ast), "Document\n");
  }

  {
    auto ast = parseTipTapDocument(R"({
      "type": "doc",
      "content": [
        {"type": "paragraph", "content": [{"type": "text", "text": "before"}]},
        {"type": "image", "attrs": {"src": "a.png"}},
        {"type": "table", "content": [{"type": "tableRow", "content": [
          {"type": "tableCell", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "hidden"}]}]}
        ]}]},
        {"type": "taskList", "content": [{"type": "taskItem", "attrs": {"checked": true}, "content": [
          {"type": "paragraph", "content": [{"type": "text", "text": "todo"}]}
        ]}]},
        {"type": "paragraph", "content": [
          {"type": "text", "text": "kept "},
          {"type": "text", "text": "plain", "marks": [{"type": "subscript"}, {"type": "unknownMark"}]},
          {"type": "text", "text": " tail"}
        ]}
      ]
    })");
    expect("unknown nodes skipped", dump(*ast),
           "Document\n"
           "  Paragraph\n"
           "    Text \"before\"\n"
           "  Paragraph\n"
           "    Text \"kept \"\n"
           "    Text \"plain\"\n"
           "    Text \" tail\"\n");
  }

  {
    auto ast = parseTipTapDocument(R"({
      "type": "doc",
      "content": [{
        "type": "paragraph",
        "content": [
          {"type": "text", "text": "A "},
          {
            "type": "factoid",
            "attrs": {
              "id": "saddle-wind",
              "color": "#7c2d12",
              "backgroundColor": "#ffedd5",
              "borderColor": "#fdba74"
            },
            "content": [
              {"type": "text", "text": "gust", "marks": [{"type": "bold"}]},
              {"type": "text", "text": " of wind"}
            ]
          },
          {"type": "text", "text": "."}
        ]
      }]
    })");
    expect("factoid inline content", dump(*ast),
           "Document\n"
           "  Paragraph\n"
           "    Text \"A \"\n"
           "    Factoid backgroundColor=#ffedd5 borderColor=#fdba74 color=#7c2d12 id=saddle-wind\n"
           "      Strong\n"
           "        Text \"gust\"\n"
           "      Text \" of wind\"\n"
           "    Text \".\"\n");
  }

  if (g_failed != 0) {
    std::cout << g_failed << " failed\n";
    return 1;
  }
  std::cout << "all parser tests passed\n";
  return 0;
}
