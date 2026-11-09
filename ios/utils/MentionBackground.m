#import "MentionBackground.h"

NSString *const MentionAttributeName = @"Mention";
NSString *const MentionIdAttributeName = @"mentionId";
NSString *const MentionLabelAttributeName = @"mentionLabel";
NSString *const MentionBackgroundColorAttributeName = @"MentionBackgroundColor";

const CGFloat ENRMMentionPaddingX = 3.0;
const CGFloat ENRMMentionPaddingY = 1.0;
static const CGFloat kMentionCornerRadius = 4.0;

@implementation MentionBackground

- (void)drawBackgroundsForGlyphRange:(NSRange)glyphsToShow
                       layoutManager:(NSLayoutManager *)layoutManager
                       textContainer:(NSTextContainer *)textContainer
                             atPoint:(CGPoint)origin
{
  NSTextStorage *textStorage = layoutManager.textStorage;
  if (!textStorage || textStorage.length == 0)
    return;

  NSRange charRange = [layoutManager characterRangeForGlyphRange:glyphsToShow actualGlyphRange:NULL];
  if (charRange.location == NSNotFound || charRange.length == 0)
    return;

  [textStorage enumerateAttribute:MentionAttributeName
                          inRange:NSMakeRange(0, textStorage.length)
                          options:0
                       usingBlock:^(id value, NSRange range, BOOL *stop) {
                         (void)stop;
                         if (!value || range.length == 0)
                           return;
                         if (NSIntersectionRange(range, charRange).length == 0)
                           return;

                         RCTUIColor *backgroundColor = [textStorage attribute:MentionBackgroundColorAttributeName
                                                                      atIndex:range.location
                                                               effectiveRange:NULL];
                         if (!backgroundColor)
                           return;

                         [self drawMentionForRange:range
                                     layoutManager:layoutManager
                                     textContainer:textContainer
                                           atPoint:origin
                                   backgroundColor:backgroundColor];
                       }];
}

/// One rounded rect per line fragment. A wrapped mention paints `box-decoration-break: clone`,
/// so each line keeps its own 10pt corners instead of stretching into a bar.
- (void)drawMentionForRange:(NSRange)range
              layoutManager:(NSLayoutManager *)layoutManager
              textContainer:(NSTextContainer *)textContainer
                    atPoint:(CGPoint)origin
            backgroundColor:(RCTUIColor *)backgroundColor
{
  NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
  if (glyphRange.location == NSNotFound || glyphRange.length == 0)
    return;

  [layoutManager
      enumerateLineFragmentsForGlyphRange:glyphRange
                               usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *tc, NSRange lineRange,
                                            BOOL *stop) {
                                 (void)rect;
                                 (void)usedRect;
                                 (void)tc;
                                 (void)stop;
                                 NSRange intersect = NSIntersectionRange(lineRange, glyphRange);
                                 if (intersect.length == 0)
                                   return;

                                 CGRect textRect =
                                     [layoutManager boundingRectForGlyphRange:intersect inTextContainer:textContainer];
                                 CGRect finalRect = CGRectInset(textRect, -ENRMMentionPaddingX, -ENRMMentionPaddingY);
                                 finalRect.origin.x += origin.x;
                                 finalRect.origin.y += origin.y;
                                 UIBezierPath *path = UIBezierPathWithRoundedRect(finalRect, kMentionCornerRadius);
                                 [backgroundColor setFill];
                                 [path fill];
                               }];
}

@end
