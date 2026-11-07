#pragma once

#include "TiptapASTNode.hpp"
#include <memory>
#include <string>

namespace Tiptap {

// Parses a Tiptap document JSON string into the display AST.
// Unknown nodes and marks are skipped. Invalid JSON yields an empty document.
std::shared_ptr<TiptapASTNode> parseTiptapDocument(const std::string &json);

} // namespace Tiptap
