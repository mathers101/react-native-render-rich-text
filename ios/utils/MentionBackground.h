#pragma once
#import "ENRMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MentionAttributeName;
extern NSString *const MentionIdAttributeName;
extern NSString *const MentionLabelAttributeName;
extern NSString *const MentionBackgroundColorAttributeName;

/// Horizontal room inside the chip, also added as kern so the fill does not
/// cover the neighboring glyphs.
extern const CGFloat ENRMMentionPaddingX;
/// Extra height above the glyphs. Small enough to stay inside the line box.
extern const CGFloat ENRMMentionPaddingY;

@interface MentionBackground : NSObject

- (void)drawBackgroundsForGlyphRange:(NSRange)glyphsToShow
                       layoutManager:(NSLayoutManager *)layoutManager
                       textContainer:(NSTextContainer *)textContainer
                             atPoint:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
