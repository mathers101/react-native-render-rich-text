#import "FactoidBackground.h"

NSString *const FactoidAttributeName = @"Factoid";
NSString *const FactoidIdAttributeName = @"factoidId";
NSString *const FactoidBackgroundColorAttributeName = @"FactoidBackgroundColor";
NSString *const FactoidBorderColorAttributeName = @"FactoidBorderColor";

static const CGFloat kFactoidCornerRadius = 4.0;
static const CGFloat kFactoidBorderWidth = 1.0;

@implementation FactoidBackground

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

  [textStorage enumerateAttribute:FactoidAttributeName
                          inRange:NSMakeRange(0, textStorage.length)
                          options:0
                       usingBlock:^(id value, NSRange range, BOOL *stop) {
                         if (!value || range.length == 0)
                           return;
                         if (NSIntersectionRange(range, charRange).length == 0)
                           return;

                         RCTUIColor *backgroundColor =
                             [textStorage attribute:FactoidBackgroundColorAttributeName atIndex:range.location effectiveRange:NULL];
                         RCTUIColor *borderColor =
                             [textStorage attribute:FactoidBorderColorAttributeName atIndex:range.location effectiveRange:NULL];
                         if (!backgroundColor && !borderColor)
                           return;

                         [self drawFactoidForRange:range
                                     layoutManager:layoutManager
                                     textContainer:textContainer
                                           atPoint:origin
                                   backgroundColor:backgroundColor
                                       borderColor:borderColor];
                       }];
}

- (void)drawFactoidForRange:(NSRange)range
              layoutManager:(NSLayoutManager *)layoutManager
              textContainer:(NSTextContainer *)textContainer
                    atPoint:(CGPoint)origin
            backgroundColor:(RCTUIColor *)backgroundColor
                borderColor:(RCTUIColor *)borderColor
{
  NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
  if (glyphRange.location == NSNotFound || glyphRange.length == 0)
    return;

  [layoutManager
      enumerateLineFragmentsForGlyphRange:glyphRange
                               usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *tc, NSRange lineRange,
                                            BOOL *stop) {
                                 (void)usedRect;
                                 (void)tc;
                                 (void)stop;
                                 NSRange intersect = NSIntersectionRange(lineRange, glyphRange);
                                 if (intersect.length == 0)
                                   return;

                                 BOOL isFirst = (intersect.location == glyphRange.location);
                                 BOOL isLast = (NSMaxRange(intersect) == NSMaxRange(glyphRange));
                                 CGRect textRect = [layoutManager boundingRectForGlyphRange:intersect inTextContainer:textContainer];
                                 // Full line height, but only as wide as the glyphs. A wrapped factoid stops at
                                 // the last glyph instead of running out to the line edge.
                                 CGRect finalRect = CGRectMake(textRect.origin.x + origin.x, rect.origin.y + origin.y,
                                                               textRect.size.width, rect.size.height);
                                 [self drawBackgroundAndBorders:finalRect
                                                backgroundColor:backgroundColor
                                                    borderColor:borderColor
                                                        isFirst:isFirst
                                                         isLast:isLast];
                               }];
}

- (void)drawBackgroundAndBorders:(CGRect)rect
                 backgroundColor:(RCTUIColor *)backgroundColor
                     borderColor:(RCTUIColor *)borderColor
                         isFirst:(BOOL)isFirst
                          isLast:(BOOL)isLast
{
  UIBezierPath *path = [self pathForRect:rect isFirst:isFirst isLast:isLast];
  if (backgroundColor) {
    [backgroundColor setFill];
    [path fill];
  }
  if (!borderColor)
    return;

  [borderColor setStroke];
  UIBezierPath *strokePath = (isFirst && isLast) ? path : [self openBorderPathForRect:rect isFirst:isFirst isLast:isLast];
  strokePath.lineWidth = kFactoidBorderWidth;
  BezierPathSetRoundStyle(strokePath);
  [strokePath stroke];
}

- (UIBezierPath *)pathForRect:(CGRect)rect isFirst:(BOOL)isFirst isLast:(BOOL)isLast
{
#if !TARGET_OS_OSX
  UIRectCorner corners = 0;
  if (isFirst)
    corners |= (UIRectCornerTopLeft | UIRectCornerBottomLeft);
  if (isLast)
    corners |= (UIRectCornerTopRight | UIRectCornerBottomRight);

  return [UIBezierPath bezierPathWithRoundedRect:rect
                               byRoundingCorners:corners
                                     cornerRadii:CGSizeMake(kFactoidCornerRadius, kFactoidCornerRadius)];
#else
  CGFloat cornerRadius = (isFirst || isLast) ? kFactoidCornerRadius : 0;
  return UIBezierPathWithRoundedRect(rect, cornerRadius);
#endif
}

- (UIBezierPath *)openBorderPathForRect:(CGRect)rect isFirst:(BOOL)isFirst isLast:(BOOL)isLast
{
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGFloat r = kFactoidCornerRadius;
  CGFloat inset = kFactoidBorderWidth / 2.0;
  CGRect insetRect = CGRectInset(rect, inset, inset);

  if (isFirst) {
    [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), insetRect.origin.y)];
    BezierPathAddLine(path, CGPointMake(insetRect.origin.x + r, insetRect.origin.y));
    BezierPathAddQuadCurve(path, CGPointMake(insetRect.origin.x, insetRect.origin.y + r),
                           CGPointMake(insetRect.origin.x, insetRect.origin.y));
    BezierPathAddLine(path, CGPointMake(insetRect.origin.x, CGRectGetMaxY(insetRect) - r));
    BezierPathAddQuadCurve(path, CGPointMake(insetRect.origin.x + r, CGRectGetMaxY(insetRect)),
                           CGPointMake(insetRect.origin.x, CGRectGetMaxY(insetRect)));
    BezierPathAddLine(path, CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(insetRect)));
  } else if (isLast) {
    [path moveToPoint:CGPointMake(rect.origin.x, insetRect.origin.y)];
    BezierPathAddLine(path, CGPointMake(CGRectGetMaxX(insetRect) - r, insetRect.origin.y));
    BezierPathAddQuadCurve(path, CGPointMake(CGRectGetMaxX(insetRect), insetRect.origin.y + r),
                           CGPointMake(CGRectGetMaxX(insetRect), insetRect.origin.y));
    BezierPathAddLine(path, CGPointMake(CGRectGetMaxX(insetRect), CGRectGetMaxY(insetRect) - r));
    BezierPathAddQuadCurve(path, CGPointMake(CGRectGetMaxX(insetRect) - r, CGRectGetMaxY(insetRect)),
                           CGPointMake(CGRectGetMaxX(insetRect), CGRectGetMaxY(insetRect)));
    BezierPathAddLine(path, CGPointMake(rect.origin.x, CGRectGetMaxY(insetRect)));
  } else {
    [path moveToPoint:CGPointMake(rect.origin.x, insetRect.origin.y)];
    BezierPathAddLine(path, CGPointMake(CGRectGetMaxX(rect), insetRect.origin.y));
    [path moveToPoint:CGPointMake(rect.origin.x, CGRectGetMaxY(insetRect))];
    BezierPathAddLine(path, CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(insetRect)));
  }
  return path;
}

@end
