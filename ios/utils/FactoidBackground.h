#pragma once
#import "ENRMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const FactoidAttributeName;
extern NSString *const FactoidIdAttributeName;
extern NSString *const FactoidBackgroundColorAttributeName;
extern NSString *const FactoidBorderColorAttributeName;

@interface FactoidBackground : NSObject

- (void)drawBackgroundsForGlyphRange:(NSRange)glyphsToShow
                       layoutManager:(NSLayoutManager *)layoutManager
                       textContainer:(NSTextContainer *)textContainer
                             atPoint:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
