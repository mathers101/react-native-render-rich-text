#pragma once
#import "ENRMUIKit.h"
#import <Foundation/Foundation.h>

@class StyleConfig;

static NSString *const kUTIPlainText = @"public.utf8-plain-text";
static NSString *const kUTIHTML = @"public.html";
static NSString *const kUTITiptap = @"net.daringfireball.tiptap";

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Copies a plain string to the platform pasteboard.
 */
void copyStringToPasteboard(NSString *string);

/// Copies a { UTI → NSString | NSData } dictionary to the platform pasteboard.
void copyItemsToPasteboard(NSDictionary<NSString *, id> *items);

/**
 * Copies attributed string to pasteboard with multiple representations
 * (plain text, Tiptap, HTML, RTFD, RTF). Receiving apps pick the richest format they support.
 */
void copyAttributedStringToPasteboard(NSAttributedString *attributedString, NSString *_Nullable tiptap,
                                      StyleConfig *_Nullable styleConfig);

/**
 * Extracts tiptap for the given range.
 * Full selection returns cached tiptap; partial selection reverse-engineers from attributes.
 */
NSString *_Nullable tiptapForRange(NSAttributedString *attributedText, NSRange range,
                                     NSString *_Nullable cachedTiptap);

/**
 * Returns remote image URLs (http/https only) from ENRMImageAttachments in the given range.
 */
NSArray<NSString *> *imageURLsInRange(NSAttributedString *attributedText, NSRange range);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
