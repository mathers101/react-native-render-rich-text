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

  [output addAttribute:FactoidAttributeName value:@YES range:range];
  [output addAttribute:FactoidIdAttributeName value:factoidId range:range];
  [output addAttribute:FactoidBackgroundColorAttributeName value:backgroundColor range:range];
  [output addAttribute:FactoidBorderColorAttributeName value:borderColor range:range];
}

@end
