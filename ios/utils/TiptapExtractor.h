#pragma once
#import "ENRMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/// Extracts tiptap from an attributed string (best-effort reconstruction).
NSString *_Nullable extractTiptapFromAttributedString(NSAttributedString *attributedText, NSRange range);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
