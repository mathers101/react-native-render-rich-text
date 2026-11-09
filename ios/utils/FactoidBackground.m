#import "FactoidBackground.h"

NSString *const FactoidAttributeName = @"Factoid";
NSString *const FactoidIdAttributeName = @"factoidId";
NSString *const FactoidBackgroundColorAttributeName = @"FactoidBackgroundColor";
NSString *const FactoidBorderColorAttributeName = @"FactoidBorderColor";
NSString *const FactoidPaddingAttributeName = @"FactoidPadding";
NSString *const FactoidTrailingPaddingAttributeName = @"FactoidTrailingPadding";

const CGFloat ENRMFactoidPadding = 5.0;

static const CGFloat kFactoidCornerRadius = 4.0;
static const CGFloat kFactoidBorderWidth = 1.0;

NSAttributedString *ENRMAttributedStringByStrippingFactoidPadding(NSAttributedString *text)
{
  if (text.length == 0)
    return text;

  __block BOOL found = NO;
  [text enumerateAttribute:FactoidPaddingAttributeName
                   inRange:NSMakeRange(0, text.length)
                   options:0
                usingBlock:^(id value, NSRange range, BOOL *stop) {
                  if (value) {
                    found = YES;
                    *stop = YES;
                  }
                }];
  if (!found)
    return text;

  NSMutableAttributedString *result = [text mutableCopy];
  [result enumerateAttribute:FactoidPaddingAttributeName
                     inRange:NSMakeRange(0, result.length)
                     options:NSAttributedStringEnumerationReverse
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                    (void)stop;
                    if (value)
                      [result deleteCharactersInRange:range];
                  }];
  return result;
}

NSString *ENRMStringByStrippingFactoidPadding(NSAttributedString *text)
{
  return ENRMAttributedStringByStrippingFactoidPadding(text).string;
}

static BOOL ENRMIsLineBreak(unichar c)
{
  return c == '\n' || c == '\r' || c == 0x2028 || c == 0x2029;
}

static BOOL ENRMIsInlineSpace(unichar c)
{
  return [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c] && !ENRMIsLineBreak(c);
}

static BOOL ENRMIsPaddingCharacter(NSAttributedString *text, NSUInteger index)
{
  return [text attribute:FactoidPaddingAttributeName atIndex:index effectiveRange:NULL] != nil;
}

/// The spacer and the joiner that glues it to the word are not ink. Neither is
/// whitespace: a wrapped line keeps its trailing space, and the chip stops on the
/// last glyph instead.
static BOOL ENRMIsInk(NSAttributedString *text, NSUInteger index)
{
  if (index >= text.length || ENRMIsPaddingCharacter(text, index))
    return NO;
  unichar c = [text.string characterAtIndex:index];
  return !ENRMIsLineBreak(c) && !ENRMIsInlineSpace(c);
}

static NSUInteger ENRMFirstInk(NSAttributedString *text, NSRange range)
{
  NSUInteger end = MIN(NSMaxRange(range), text.length);
  for (NSUInteger index = range.location; index < end; index++) {
    if (ENRMIsInk(text, index))
      return index;
  }
  return NSNotFound;
}

static NSUInteger ENRMLastInk(NSAttributedString *text, NSRange range)
{
  NSUInteger end = MIN(NSMaxRange(range), text.length);
  for (NSUInteger index = end; index > range.location; index--) {
    if (ENRMIsInk(text, index - 1))
      return index - 1;
  }
  return NSNotFound;
}

/// Container-x of the glyph. `endX` is where the next glyph starts when it shares
/// the line, which includes kern. At the end of the line the glyph bounds omit
/// trailing kern, so the caller adds `FactoidTrailingPadding` itself.
/// Any out-parameter may be NULL.
static void ENRMGlyphHorizontalSpan(NSLayoutManager *layoutManager, NSUInteger charIndex,
                                    NSTextContainer *textContainer, CGFloat *originX, CGFloat *endX, BOOL *endIncludesKern)
{
  CGFloat origin = 0;
  CGFloat end = 0;
  BOOL includesKern = NO;

  if (charIndex < layoutManager.textStorage.length) {
    NSUInteger glyph = [layoutManager glyphIndexForCharacterAtIndex:charIndex];
    if (glyph < layoutManager.numberOfGlyphs) {
      NSRange lineGlyphRange;
      CGRect line = [layoutManager lineFragmentRectForGlyphAtIndex:glyph effectiveRange:&lineGlyphRange];
      CGPoint location = [layoutManager locationForGlyphAtIndex:glyph];
      origin = line.origin.x + location.x;
      end = origin;

      if (glyph + 1 < layoutManager.numberOfGlyphs && NSLocationInRange(glyph + 1, lineGlyphRange)) {
        CGPoint next = [layoutManager locationForGlyphAtIndex:glyph + 1];
        end = line.origin.x + next.x;
        includesKern = YES;
      } else {
        CGSize attachment = [layoutManager attachmentSizeForGlyphAtIndex:glyph];
        if (attachment.width > 0) {
          end = origin + attachment.width;
        } else {
          CGRect bounds = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyph, 1) inTextContainer:textContainer];
          if (bounds.size.width > 0 && bounds.size.width < line.size.width - 1) {
            end = CGRectGetMaxX(bounds);
          } else {
            UIFont *font = [layoutManager.textStorage attribute:NSFontAttributeName atIndex:charIndex effectiveRange:NULL];
            if (!font)
              font = [UIFont systemFontOfSize:17];
            NSRange characters = [layoutManager.textStorage.string rangeOfComposedCharacterSequenceAtIndex:charIndex];
            NSString *character = [layoutManager.textStorage.string substringWithRange:characters];
            end = origin + [character sizeWithAttributes:@{NSFontAttributeName : font}].width;
          }
        }
      }
    }
  }

  if (originX)
    *originX = origin;
  if (endX)
    *endX = end;
  if (endIncludesKern)
    *endIncludesKern = includesKern;
}

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

  NSAttributedString *text = layoutManager.textStorage;
  NSUInteger factoidFirstInk = ENRMFirstInk(text, range);
  NSUInteger factoidLastInk = ENRMLastInk(text, range);
  if (factoidFirstInk == NSNotFound || factoidLastInk == NSNotFound)
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

                                 NSRange lineChars = [layoutManager characterRangeForGlyphRange:intersect
                                                                               actualGlyphRange:NULL];
                                 lineChars = NSIntersectionRange(lineChars, range);
                                 if (lineChars.length == 0 || lineChars.location >= text.length)
                                   return;

                                 // Skip a line the breaker left with only the spacer. Drawing it would
                                 // paint a chip at the end of the previous line after the word wrapped.
                                 NSUInteger lineInk = ENRMFirstInk(text, lineChars);
                                 if (lineInk == NSNotFound)
                                   return;

                                 NSUInteger leftChar = NSNotFound;
                                 NSUInteger end = MIN(NSMaxRange(lineChars), text.length);
                                 for (NSUInteger index = lineChars.location; index < end; index++) {
                                   unichar c = [text.string characterAtIndex:index];
                                   if (ENRMIsLineBreak(c))
                                     continue;
                                   if (!ENRMIsPaddingCharacter(text, index) && ENRMIsInlineSpace(c))
                                     continue;
                                   leftChar = index;
                                   break;
                                 }
                                 NSUInteger rightChar = ENRMLastInk(text, lineChars);
                                 if (leftChar == NSNotFound || rightChar == NSNotFound)
                                   return;

                                 CGFloat left = 0;
                                 ENRMGlyphHorizontalSpan(layoutManager, leftChar, textContainer, &left, NULL, NULL);

                                 CGFloat rightOrigin = 0;
                                 CGFloat right = 0;
                                 BOOL rightIncludesKern = NO;
                                 ENRMGlyphHorizontalSpan(layoutManager, rightChar, textContainer, &rightOrigin, &right,
                                                         &rightIncludesKern);
                                 if (!rightIncludesKern) {
                                   NSNumber *trailing = [text attribute:FactoidTrailingPaddingAttributeName
                                                                atIndex:rightChar
                                                         effectiveRange:NULL];
                                   if (trailing)
                                     right += trailing.doubleValue;
                                 }

                                 CGFloat minX = MIN(left, right);
                                 CGFloat maxX = MAX(left, right);
                                 if (maxX - minX < 0.5)
                                   return;

                                 BOOL isFirst = NSLocationInRange(factoidFirstInk, lineChars);
                                 BOOL isLast = NSLocationInRange(factoidLastInk, lineChars);
                                 // Full line height. Width stops at the last glyph, including the edge
                                 // gap when it is on this line, rather than running out to the line edge.
                                 CGRect finalRect = CGRectMake(minX + origin.x, rect.origin.y + origin.y, maxX - minX,
                                                               rect.size.height);
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
