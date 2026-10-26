#pragma once

#include "MarkdownASTNode.hpp"
#include <memory>
#include <string>

namespace Markdown {

// Parses a TipTap document JSON string into the display AST.
// Unknown nodes and marks are skipped. Invalid JSON yields an empty document.
std::shared_ptr<MarkdownASTNode> parseTipTapDocument(const std::string &json);

} // namespace Markdown
