#pragma once

#import <Foundation/Foundation.h>

@class TiptapASTNode;
@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/// Shared code block node semantics, used by both tiptap flavors so the
/// meaning of a CodeBlock AST node (its text, language, fence) is defined in
/// one place. Language display names come from the shared C++ core
/// (cpp/highlight/CodeBlockLanguages.hpp) so all platforms label fences
/// identically.

NSString *ENRMCodeBlockExtractCode(TiptapASTNode *node);
NSString *_Nullable ENRMCodeBlockLanguage(TiptapASTNode *node);
NSString *ENRMCodeBlockFenceChar(TiptapASTNode *node);
NSString *ENRMCodeBlockFencedTiptap(NSString *code, NSString *_Nullable language, NSString *fenceChar);
NSString *ENRMCodeBlockDisplayLanguageName(NSString *_Nullable language);

/// Applies the flavor-independent code block text attributes (code font,
/// color, line height, forced-LTR left-aligned paragraph) to the range.
/// Callers layer their container-specific paragraph adjustments on top (the
/// commonmark span flavor adds padding indents; the github block view has
/// none).
void ENRMApplyCodeBlockTextAttributes(NSMutableAttributedString *string, NSRange range, StyleConfig *config);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
