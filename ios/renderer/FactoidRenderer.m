#import "FactoidRenderer.h"
#import "FactoidBackground.h"
#import "TiptapASTNode.h"
#import "RenderContext.h"
#import "RendererFactory.h"
#import "StyleConfig.h"

static RCTUIColor *ENRMColorFromString(NSString *value)
{
  if (value.length == 0)
    return nil;

  NSString *trimmed = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (trimmed.length == 0)
    return nil;

  if ([trimmed characterAtIndex:0] == '#') {
    NSString *hex = [trimmed substringFromIndex:1];
    if (hex.length != 6 && hex.length != 8)
      return nil;
    unsigned int rgba = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    if (![scanner scanHexInt:&rgba] || !scanner.isAtEnd)
      return nil;
    CGFloat alpha = 1.0;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    if (hex.length == 8) {
      alpha = ((rgba >> 24) & 0xFF) / 255.0;
      red = ((rgba >> 16) & 0xFF) / 255.0;
      green = ((rgba >> 8) & 0xFF) / 255.0;
      blue = (rgba & 0xFF) / 255.0;
    } else {
      red = ((rgba >> 16) & 0xFF) / 255.0;
      green = ((rgba >> 8) & 0xFF) / 255.0;
      blue = (rgba & 0xFF) / 255.0;
    }
    return [RCTUIColor colorWithRed:red green:green blue:blue alpha:alpha];
  }

  static NSDictionary<NSString *, RCTUIColor *> *namedColors;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    namedColors = @{
      @"black" : [RCTUIColor blackColor],
      @"darkgray" : [RCTUIColor darkGrayColor],
      @"darkgrey" : [RCTUIColor darkGrayColor],
      @"gray" : [RCTUIColor grayColor],
      @"grey" : [RCTUIColor grayColor],
      @"lightgray" : [RCTUIColor lightGrayColor],
      @"lightgrey" : [RCTUIColor lightGrayColor],
      @"white" : [RCTUIColor whiteColor],
      @"red" : [RCTUIColor redColor],
      @"green" : [RCTUIColor greenColor],
      @"blue" : [RCTUIColor blueColor],
      @"yellow" : [RCTUIColor yellowColor],
      @"cyan" : [RCTUIColor cyanColor],
      @"aqua" : [RCTUIColor cyanColor],
      @"magenta" : [RCTUIColor magentaColor],
      @"fuchsia" : [RCTUIColor magentaColor],
      @"lime" : [RCTUIColor colorWithRed:0 green:1 blue:0 alpha:1],
      @"maroon" : [RCTUIColor colorWithRed:0.5 green:0 blue:0 alpha:1],
      @"navy" : [RCTUIColor colorWithRed:0 green:0 blue:0.5 alpha:1],
      @"olive" : [RCTUIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1],
      @"purple" : [RCTUIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1],
      @"silver" : [RCTUIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1],
      @"teal" : [RCTUIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1],
    };
  });
  return namedColors[trimmed.lowercaseString];
}

/// Width-only spacer. Height stays inside the line box so the gap does not grow the line.
@interface ENRMFactoidPaddingAttachment : NSTextAttachment
@end

@implementation ENRMFactoidPaddingAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex
{
  (void)textContainer;
  (void)lineFrag;
  (void)position;
  (void)charIndex;
  return CGRectMake(0, 0, ENRMFactoidPadding, 1);
}

@end

static BOOL ENRMIsLineBreak(unichar c)
{
  return c == '\n' || c == '\r' || c == 0x2028 || c == 0x2029;
}

static BOOL ENRMIsInlineSpace(unichar c)
{
  return [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c] && !ENRMIsLineBreak(c);
}

/// Ink is a visible factoid character. A link pill is ink too, and the caller
/// refuses to pad it: the pill already has its own padding.
static BOOL ENRMIsInk(NSAttributedString *text, NSUInteger index)
{
  if (index >= text.length)
    return NO;
  unichar c = [text.string characterAtIndex:index];
  return !ENRMIsLineBreak(c) && !ENRMIsInlineSpace(c);
}

static void ENRMShiftRanges(NSMutableArray<NSValue *> *ranges, NSUInteger index, NSUInteger delta)
{
  if (delta == 0)
    return;
  for (NSUInteger i = 0; i < ranges.count; i++) {
    NSRange range = ranges[i].rangeValue;
    if (range.location >= index)
      range.location += delta;
    else if (NSMaxRange(range) > index)
      range.length += delta;
    else
      continue;
    ranges[i] = [NSValue valueWithRange:range];
  }
}

/// Reserves `ENRMFactoidPadding` before the first word and after the last.
/// The leading gap is an attachment glued to the following character with a word
/// joiner. A break is still allowed before the attachment, so when the word wraps
/// the gap starts the new line with it. Kern on the previous character would stay
/// at the end of the previous line. A pill is left alone.
static NSRange ENRMApplyFactoidPadding(NSMutableAttributedString *output, RenderContext *context, NSRange range)
{
  if (range.length == 0 || NSMaxRange(range) > output.length)
    return range;

  NSUInteger firstInk = NSNotFound;
  NSUInteger lastInk = NSNotFound;
  NSUInteger end = NSMaxRange(range);
  for (NSUInteger index = range.location; index < end; index++) {
    if (!ENRMIsInk(output, index))
      continue;
    if (firstInk == NSNotFound)
      firstInk = index;
    lastInk = index;
  }
  if (firstInk == NSNotFound)
    return range;

  if ([output attribute:NSAttachmentAttributeName atIndex:lastInk effectiveRange:NULL] == nil) {
    NSRange composed = [output.string rangeOfComposedCharacterSequenceAtIndex:lastInk];
    NSUInteger kernIndex = NSMaxRange(composed) - 1;
    NSNumber *existing = [output attribute:NSKernAttributeName atIndex:kernIndex effectiveRange:NULL];
    [output addAttribute:NSKernAttributeName
                   value:@((existing ? existing.doubleValue : 0) + ENRMFactoidPadding)
                   range:NSMakeRange(kernIndex, 1)];
    [output addAttribute:FactoidTrailingPaddingAttributeName
                   value:@(ENRMFactoidPadding)
                   range:NSMakeRange(kernIndex, 1)];
  }

  if ([output attribute:NSAttachmentAttributeName atIndex:firstInk effectiveRange:NULL] != nil)
    return range;

  NSDictionary *seed = [output attributesAtIndex:firstInk effectiveRange:NULL];
  NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
  for (NSAttributedStringKey key in @[
         NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, NSBaselineOffsetAttributeName
       ]) {
    if (seed[key])
      attrs[key] = seed[key];
  }
  attrs[FactoidPaddingAttributeName] = @YES;

  ENRMFactoidPaddingAttachment *spacer = [ENRMFactoidPaddingAttachment new];
  spacer.bounds = CGRectMake(0, 0, ENRMFactoidPadding, 1);
  NSMutableDictionary *spacerAttrs = [attrs mutableCopy];
  spacerAttrs[NSAttachmentAttributeName] = spacer;

  NSMutableAttributedString *prefix =
      [[NSMutableAttributedString alloc] initWithString:@"\uFFFC" attributes:spacerAttrs];
  // U+2060 forbids a break on either side, so the spacer cannot sit on the previous line.
  [prefix appendAttributedString:[[NSAttributedString alloc] initWithString:@"\u2060" attributes:attrs]];
  [output insertAttributedString:prefix atIndex:firstInk];

  ENRMShiftRanges(context.linkRanges, firstInk, prefix.length);
  ENRMShiftRanges(context.imageRanges, firstInk, prefix.length);
  return NSMakeRange(range.location, range.length + prefix.length);
}

static RCTUIColor *ENRMFactoidColor(NSString *value, RCTUIColor *styleColor, unsigned int rgb)
{
  RCTUIColor *parsed = ENRMColorFromString(value);
  if (parsed)
    return parsed;
  if (styleColor)
    return styleColor;
  return [RCTUIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

@implementation FactoidRenderer

- (id)takeContextSnapshot:(RenderContext *)context
{
  return [context snapshotScope];
}

- (void)renderNodeContent:(TiptapASTNode *)node
                     into:(NSMutableAttributedString *)output
                  context:(RenderContext *)context
{
  NSString *factoidId = node.attributes[@"id"] ?: @"";
  // A node attribute replaces the matching textStyle.factoid color. The RGB values are the
  // same defaults JS applies when textStyle.factoid omits a color.
  RCTUIColor *textColor = ENRMFactoidColor(node.attributes[@"color"], _config.factoidColor, 0x205710);
  RCTUIColor *backgroundColor =
    ENRMFactoidColor(node.attributes[@"backgroundColor"], _config.factoidBackgroundColor, 0x9BFC6E);
  RCTUIColor *borderColor =
    ENRMFactoidColor(node.attributes[@"borderColor"], _config.factoidBorderColor, 0x23670D);

  // Inline children keep the surrounding font. The text color becomes their base color.
  BlockStyle *block = [context getBlockStyle];
  UIFont *font = block.cachedFont;
  if (!font) {
    font = [context cachedFontForSize:block.fontSize family:block.fontFamily weight:block.fontWeight];
  }
  [context setBlockStyle:context.currentBlockType
                    font:font
                   color:textColor
            headingLevel:context.currentHeadingLevel];

  NSUInteger start = output.length;
  [_rendererFactory renderChildrenOfNode:node into:output context:context];
  NSRange range = NSMakeRange(start, output.length > start ? output.length - start : 0);
  if (range.length == 0)
    return;

  range = ENRMApplyFactoidPadding(output, context, range);

  [output addAttribute:FactoidAttributeName value:@YES range:range];
  [output addAttribute:FactoidIdAttributeName value:factoidId range:range];
  [output addAttribute:FactoidBackgroundColorAttributeName value:backgroundColor range:range];
  [output addAttribute:FactoidBorderColorAttributeName value:borderColor range:range];
}

@end
