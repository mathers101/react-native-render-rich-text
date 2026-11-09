#pragma once
#import "ENRMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const FactoidAttributeName;
extern NSString *const FactoidIdAttributeName;
extern NSString *const FactoidBackgroundColorAttributeName;
extern NSString *const FactoidBorderColorAttributeName;

/// Gap between the chip edge and the factoid text, in points. The Android span
/// uses the same value in its text-layout units.
extern const CGFloat ENRMFactoidPadding;
/// Set on the spacer character and the word joiner that keeps it with the text.
/// Copy, HTML, and accessibility drop these characters.
extern NSString *const FactoidPaddingAttributeName;
/// Points of extra advance after the last ink character. Absent on every other character.
extern NSString *const FactoidTrailingPaddingAttributeName;

#ifdef __cplusplus
extern "C" {
#endif

NSAttributedString *ENRMAttributedStringByStrippingFactoidPadding(NSAttributedString *text);
NSString *ENRMStringByStrippingFactoidPadding(NSAttributedString *text);

#ifdef __cplusplus
}
#endif

@interface FactoidBackground : NSObject

- (void)drawBackgroundsForGlyphRange:(NSRange)glyphsToShow
                       layoutManager:(NSLayoutManager *)layoutManager
                       textContainer:(NSTextContainer *)textContainer
                             atPoint:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
