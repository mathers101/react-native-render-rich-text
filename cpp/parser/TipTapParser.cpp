#include "TipTapParser.hpp"

#include <nlohmann/json.hpp>

#include <string>

namespace Markdown {
namespace {

using json = nlohmann::json;

std::shared_ptr<MarkdownASTNode> makeNode(NodeType type) {
  return std::make_shared<MarkdownASTNode>(type);
}

std::shared_ptr<MarkdownASTNode> parseNode(const json &node);

bool isObject(const json &value) {
  return value.is_object();
}

std::string textOf(const json &node) {
  if (!node.contains("text") || !node["text"].is_string()) {
    return "";
  }
  return node["text"].get<std::string>();
}

const json *markOfType(const json &node, const char *typeA, const char *typeB = nullptr) {
  if (!node.contains("marks") || !node["marks"].is_array()) {
    return nullptr;
  }
  const json *found = nullptr;
  for (const auto &mark : node["marks"]) {
    if (!mark.is_object() || !mark.contains("type") || !mark["type"].is_string()) {
      continue;
    }
    const auto &type = mark["type"].get_ref<const std::string &>();
    if (type == typeA || (typeB != nullptr && type == typeB)) {
      found = &mark;
    }
  }
  return found;
}

std::shared_ptr<MarkdownASTNode> wrap(NodeType type, std::shared_ptr<MarkdownASTNode> child) {
  auto node = makeNode(type);
  node->addChild(std::move(child));
  return node;
}

// Marks are flat on a TipTap text node. Nest them in a fixed order so the
// renderers see the same shape markdown used to produce: code inside bold
// inside italic inside strike inside underline inside highlight inside link.
std::shared_ptr<MarkdownASTNode> parseText(const json &node) {
  auto text = makeNode(NodeType::Text);
  text->content = textOf(node);
  std::shared_ptr<MarkdownASTNode> current = text;

  if (markOfType(node, "code") != nullptr) {
    current = wrap(NodeType::Code, std::move(current));
  }
  if (markOfType(node, "bold", "strong") != nullptr) {
    current = wrap(NodeType::Strong, std::move(current));
  }
  if (markOfType(node, "italic", "em") != nullptr) {
    current = wrap(NodeType::Emphasis, std::move(current));
  }
  if (markOfType(node, "strike", "strikethrough") != nullptr) {
    current = wrap(NodeType::Strikethrough, std::move(current));
  }
  if (markOfType(node, "underline") != nullptr) {
    current = wrap(NodeType::Underline, std::move(current));
  }
  if (markOfType(node, "highlight") != nullptr) {
    current = wrap(NodeType::Highlight, std::move(current));
  }
  if (const json *link = markOfType(node, "link")) {
    auto linked = makeNode(NodeType::Link);
    if (link->contains("attrs") && (*link)["attrs"].is_object()) {
      const auto &attrs = (*link)["attrs"];
      if (attrs.contains("href") && attrs["href"].is_string()) {
        linked->setAttribute("url", attrs["href"].get<std::string>());
      }
    }
    linked->addChild(std::move(current));
    current = std::move(linked);
  }
  return current;
}

void addChildren(MarkdownASTNode &parent, const json &node) {
  if (!node.contains("content") || !node["content"].is_array()) {
    return;
  }
  for (const auto &child : node["content"]) {
    if (auto parsed = parseNode(child)) {
      parent.addChild(std::move(parsed));
    }
  }
}

int intAttr(const json &node, const char *key, int fallback) {
  if (!node.contains("attrs") || !node["attrs"].is_object()) {
    return fallback;
  }
  const auto &attrs = node["attrs"];
  if (!attrs.contains(key)) {
    return fallback;
  }
  const auto &value = attrs[key];
  if (value.is_number_integer()) {
    return value.get<int>();
  }
  if (value.is_number()) {
    return static_cast<int>(value.get<double>());
  }
  return fallback;
}

std::string stringAttr(const json &node, const char *key) {
  if (!node.contains("attrs") || !node["attrs"].is_object()) {
    return "";
  }
  const auto &attrs = node["attrs"];
  if (!attrs.contains(key) || !attrs[key].is_string()) {
    return "";
  }
  return attrs[key].get<std::string>();
}

std::shared_ptr<MarkdownASTNode> parseNode(const json &node) {
  if (!isObject(node) || !node.contains("type") || !node["type"].is_string()) {
    return nullptr;
  }
  const auto &type = node["type"].get_ref<const std::string &>();

  if (type == "text") {
    return parseText(node);
  }
  if (type == "hardBreak") {
    return makeNode(NodeType::LineBreak);
  }

  std::shared_ptr<MarkdownASTNode> parsed;
  if (type == "doc") {
    parsed = makeNode(NodeType::Document);
  } else if (type == "paragraph") {
    parsed = makeNode(NodeType::Paragraph);
  } else if (type == "heading") {
    parsed = makeNode(NodeType::Heading);
    int level = intAttr(node, "level", 1);
    if (level < 1) {
      level = 1;
    }
    parsed->setAttribute("level", std::to_string(level));
  } else if (type == "bulletList") {
    parsed = makeNode(NodeType::UnorderedList);
  } else if (type == "orderedList") {
    parsed = makeNode(NodeType::OrderedList);
    int start = intAttr(node, "start", 1);
    if (start != 1) {
      parsed->setAttribute("start", std::to_string(start));
    }
  } else if (type == "listItem") {
    parsed = makeNode(NodeType::ListItem);
  } else if (type == "blockquote") {
    parsed = makeNode(NodeType::Blockquote);
  } else if (type == "codeBlock") {
    parsed = makeNode(NodeType::CodeBlock);
    std::string language = stringAttr(node, "language");
    if (!language.empty()) {
      parsed->setAttribute("language", language);
    }
  } else if (type == "horizontalRule") {
    parsed = makeNode(NodeType::ThematicBreak);
  } else {
    // Tables, images, task lists, and anything else are skipped with their children.
    return nullptr;
  }

  addChildren(*parsed, node);
  return parsed;
}

} // namespace

std::shared_ptr<MarkdownASTNode> parseTipTapDocument(const std::string &jsonText) {
  if (jsonText.empty()) {
    return makeNode(NodeType::Document);
  }
  json parsed = json::parse(jsonText, nullptr, false);
  if (parsed.is_discarded() || !parsed.is_object()) {
    return makeNode(NodeType::Document);
  }
  auto root = parseNode(parsed);
  if (!root) {
    return makeNode(NodeType::Document);
  }
  if (root->type != NodeType::Document) {
    auto document = makeNode(NodeType::Document);
    document->addChild(std::move(root));
    return document;
  }
  return root;
}

} // namespace Markdown
