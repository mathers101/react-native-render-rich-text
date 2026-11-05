#import "MentionRenderer.h"
#import "FontUtils.h"
#import "MentionBackground.h"
#import "RenderContext.h"
#import "RendererFactory.h"
#import "StyleConfig.h"
#import "TiptapASTNode.h"

static RCTUIColor *ENRMMentionColor(RCTUIColor *styleColor, unsigned int rgb)
{
  if (styleColor)
    return styleColor;
  return [RCTUIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

/// Semibold is the iOS weight for a name sitting in body text. Android uses medium.
static UIFont *ENRMSemiboldFont(UIFont *font)
{
  if (!font)
    return [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];

  UIFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorByAddingAttributes:@{
    UIFontDescriptorTraitsAttribute : @{UIFontWeightTrait : @(UIFontWeightSemibold)}
  }];
  UIFont *resolved = [UIFont fontWithDescriptor:descriptor size:font.pointSize];
  return resolved ?: font;
}

static NSString *ENRMMentionText(NSString *mentionId, NSString *label)
{
  NSCharacterSet *spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *name = label;
  if (name.length == 0 || [[name stringByTrimmingCharactersInSet:spaces] length] == 0)
    name = mentionId ?: @"";
  if (name.length == 0 || [[name stringByTrimmingCharactersInSet:spaces] length] == 0)
    name = @"";
  return [@"@" stringByAppendingString:name];
}

static void ENRMAddKern(NSMutableAttributedString *output, NSUInteger index, CGFloat extra)
{
  if (index >= output.length)
    return;
  NSNumber *existing = [output attribute:NSKernAttributeName atIndex:index effectiveRange:NULL];
  [output addAttribute:NSKernAttributeName
                 value:@(existing.doubleValue + extra)
                 range:NSMakeRange(index, 1)];
}

@implementation MentionRenderer

- (void)renderNodeContent:(TiptapASTNode *)node
                     into:(NSMutableAttributedString *)output
                  context:(RenderContext *)context
{
  NSString *mentionId = node.attributes[@"id"] ?: @"";
  NSString *label = node.attributes[@"label"] ?: @"";
  NSString *text = ENRMMentionText(mentionId, label);

  BlockStyle *block = [context getBlockStyle];
  UIFont *font = block.cachedFont;
  if (!font && block)
    font = [context cachedFontForSize:block.fontSize family:block.fontFamily weight:block.fontWeight];

  // Same defaults JS applies when textStyle.mention omits a color.
  RCTUIColor *textColor = ENRMMentionColor(_config.mentionColor, 0x1D4ED8);
  RCTUIColor *backgroundColor = ENRMMentionColor(_config.mentionBackgroundColor, 0xDBEAFE);

  NSDictionary *baseAttrs = block ? [context getTextAttributes] : @{};
  NSMutableDictionary *attrs = [baseAttrs mutableCopy] ?: [NSMutableDictionary dictionary];
  attrs[NSFontAttributeName] = ENRMSemiboldFont(font);
  attrs[NSForegroundColorAttributeName] = textColor;
  attrs[MentionAttributeName] = @YES;
  attrs[MentionIdAttributeName] = mentionId;
  attrs[MentionLabelAttributeName] = label;
  attrs[MentionBackgroundColorAttributeName] = backgroundColor;

  NSUInteger start = output.length;
  [output appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attrs]];
  if (text.length == 0)
    return;

  // The fill is wider than the glyphs. Kern reserves that room so it sits in
  // the gap instead of painting over the words on either side.
  if (start > 0) {
    unichar previous = [output.string characterAtIndex:start - 1];
    if (previous != '\n' && previous != 0x2028 && previous != 0x2029)
      ENRMAddKern(output, start - 1, ENRMMentionPaddingX);
  }
  ENRMAddKern(output, start + text.length - 1, ENRMMentionPaddingX);
}

@end
