#import "BlockquoteRenderer.h"
#import "BlockquoteBorder.h"
#import "FontUtils.h"
#import "LastElementUtils.h"
#import "ListItemRenderer.h"
#import "TiptapASTNode.h"
#import "ParagraphStyleUtils.h"
#import "RenderContext.h"
#import "RendererFactory.h"
#import "StyleConfig.h"

static NSString *const kNestedInfoDepthKey = @"depth";
static NSString *const kNestedInfoRangeKey = @"range";

@implementation BlockquoteRenderer

- (id)takeContextSnapshot:(RenderContext *)context
{
  return [context snapshotScope];
}

- (void)renderNodeContent:(TiptapASTNode *)node
                     into:(NSMutableAttributedString *)output
                  context:(RenderContext *)context
{
  if (output.length > 0 && ![output.string hasSuffix:@"\n"]) {
    [output appendAttributedString:kNewlineAttributedString];
  }

  NSInteger currentDepth = context.blockquoteDepth;
  context.blockquoteDepth = currentDepth + 1;

  [context setBlockStyle:BlockTypeBlockquote
                    font:[_config blockquoteFont]
                   color:[_config blockquoteColor]
            headingLevel:0];

  NSUInteger start = output.length;
  [_rendererFactory renderChildrenOfNode:node into:output context:context];

  NSUInteger end = output.length;
  if (end <= start) {
    return;
  }

  [self applyStylingAndSpacing:output start:start end:end currentDepth:currentDepth context:context];
}

#pragma mark - Styling and Spacing

// A block margin spacer is a 1pt line whose only job is paragraphSpacing.
// Padding spacers are taller and carry no paragraphSpacing, so they stay.
static BOOL ENRMIsMarginSpacerLine(NSAttributedString *output, NSUInteger index)
{
  if (index >= output.length || [output.string characterAtIndex:index] != '\n')
    return NO;
  if (index > 0 && [output.string characterAtIndex:index - 1] != '\n')
    return NO;

  NSParagraphStyle *style = [output attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:NULL];
  return style && style.paragraphSpacing > 0 && style.minimumLineHeight > 0 &&
         style.minimumLineHeight == style.maximumLineHeight && style.minimumLineHeight <= 1.5;
}

// Deletes a trailing margin spacer from [start, end) and reports its spacing.
// The spacer's paragraphSpacing would otherwise fall between the last line and
// the quote's bottom padding, inside the background.
static CGFloat ENRMRemoveTrailingMarginSpacer(NSMutableAttributedString *output, NSUInteger start, NSUInteger *endInOut)
{
  NSUInteger end = *endInOut;
  if (end <= start)
    return 0;

  NSUInteger newline = end - 1;
  if (!ENRMIsMarginSpacerLine(output, newline))
    return 0;

  NSParagraphStyle *style = [output attribute:NSParagraphStyleAttributeName atIndex:newline effectiveRange:NULL];
  CGFloat margin = style.paragraphSpacing;
  [output deleteCharactersInRange:NSMakeRange(newline, 1)];
  *endInOut = newline;
  return margin;
}

// paragraphSpacing of the content line that the bottom padding spacer follows.
// That gap is inside the box: the padding row is part of the quote, so the
// margin paints as extra space under the text. Returns 0 when this box has no
// bottom padding row (the margin then sits past the background).
static CGFloat ENRMParagraphSpacingBeforeBottomSpacer(NSAttributedString *output, NSRange boxRange)
{
  if (boxRange.length < 2 || NSMaxRange(boxRange) > output.length)
    return 0;

  NSUInteger spacerIndex = NSMaxRange(boxRange) - 1;
  if (![output attribute:BlockquoteSpacerAttributeName atIndex:spacerIndex effectiveRange:NULL])
    return 0;

  NSRange paragraph = [output.string paragraphRangeForRange:NSMakeRange(spacerIndex - 1, 1)];
  NSUInteger paraEnd = MIN(NSMaxRange(paragraph), spacerIndex);
  if (paraEnd == 0 || paraEnd <= paragraph.location)
    return 0;

  NSParagraphStyle *style = [output attribute:NSParagraphStyleAttributeName atIndex:paraEnd - 1 effectiveRange:NULL];
  return style ? style.paragraphSpacing : 0;
}

static void ENRMClearParagraphSpacingBeforeBottomSpacer(NSMutableAttributedString *output, NSRange boxRange)
{
  if (ENRMParagraphSpacingBeforeBottomSpacer(output, boxRange) <= 0)
    return;

  NSUInteger spacerIndex = NSMaxRange(boxRange) - 1;
  NSRange paragraph = [output.string paragraphRangeForRange:NSMakeRange(spacerIndex - 1, 1)];
  NSUInteger clearStart = MAX(paragraph.location, boxRange.location);
  NSUInteger clearEnd = MIN(NSMaxRange(paragraph), spacerIndex);
  if (clearEnd <= clearStart)
    return;

  NSRange clearRange = NSMakeRange(clearStart, clearEnd - clearStart);
  [output enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:clearRange
                     options:0
                  usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL *stop) {
                    if (!style || style.paragraphSpacing <= 0)
                      return;
                    NSMutableParagraphStyle *updated = [style mutableCopy];
                    updated.paragraphSpacing = 0;
                    [output addAttribute:NSParagraphStyleAttributeName value:updated range:range];
                  }];
}

- (void)applyStylingAndSpacing:(NSMutableAttributedString *)output
                         start:(NSUInteger)start
                           end:(NSUInteger)end
                  currentDepth:(NSInteger)currentDepth
                       context:(RenderContext *)context
{
  // Last child's margin, lifted off the box. A root quote drops it (the quote's
  // own margin is applied below). A nested quote puts it back after the box so
  // the parent still gets a gap before the next sibling.
  CGFloat liftedMargin = ENRMRemoveTrailingMarginSpacer(output, start, &end);
  if (end <= start)
    return;

  NSUInteger contentStart = start;
  if (currentDepth == 0) {
    contentStart += applyBlockSpacingBefore(output, start, [_config blockquoteMarginTop]);
  }

  // nested quotes pad their own box (matching web CSS padding)
  CGFloat padding = [_config blockquotePadding];
  NSUInteger topPadLength = 0;
  NSUInteger bottomPadLength = 0;
  if (padding > 0) {
    NSMutableParagraphStyle *topSpacerStyle = [context spacerStyleWithHeight:padding spacing:0];
    NSAttributedString *topSpacer = [[NSAttributedString alloc]
        initWithString:@"\n"
            attributes:@{NSParagraphStyleAttributeName : topSpacerStyle, BlockquoteSpacerAttributeName : @YES}];
    [output insertAttributedString:topSpacer atIndex:contentStart];
    topPadLength = 1;

    NSUInteger bottomSpacerLocation = output.length;
    [output appendAttributedString:kNewlineAttributedString];
    NSMutableParagraphStyle *bottomSpacerStyle = [context spacerStyleWithHeight:padding spacing:0];
    [output addAttributes:@{NSParagraphStyleAttributeName : bottomSpacerStyle, BlockquoteSpacerAttributeName : @YES}
                    range:NSMakeRange(bottomSpacerLocation, 1)];
    bottomPadLength = 1;
  }

  NSRange blockquoteRange = NSMakeRange(contentStart, (end - start) + topPadLength + bottomPadLength);
  NSRange innerRange = NSMakeRange(contentStart + topPadLength, end - start);
  CGFloat levelSpacing = [_config blockquoteBorderWidth] + [_config blockquoteGapWidth];
  NSArray<NSDictionary *> *nestedInfo = [self collectNestedBlockquotes:output range:innerRange depth:currentDepth];

  // Read before base styling. That pass copies the first run's paragraph style
  // across the quote and would report the wrong trailing margin.
  CGFloat contentMargin = ENRMParagraphSpacingBeforeBottomSpacer(output, blockquoteRange);

  // Apply base styling (indentation, depth, background, line height)
  [self applyBaseBlockquoteStyle:output
                        boxRange:blockquoteRange
                      innerRange:innerRange
                           depth:currentDepth
                    levelSpacing:levelSpacing
                 backgroundColor:[_config blockquoteBackgroundColor]
                      lineHeight:[_config blockquoteLineHeight]];

  // Re-apply nested blockquote styles to restore their correct indentation
  // (applyBaseBlockquoteStyle overwrites nested indents with the parent's indent)
  [self reapplyNestedStyles:output nestedInfo:nestedInfo levelSpacing:levelSpacing];

  // Base styling copies the first paragraph's margin onto the last line, which
  // puts it back between the text and the bottom padding row.
  ENRMClearParagraphSpacingBeforeBottomSpacer(output, blockquoteRange);
  for (NSDictionary *info in nestedInfo) {
    ENRMClearParagraphSpacingBeforeBottomSpacer(output, [info[kNestedInfoRangeKey] rangeValue]);
  }

  if (currentDepth > 0) {
    CGFloat margin = liftedMargin > 0 ? liftedMargin : contentMargin;
    if (margin > 0) {
      NSUInteger spacerLocation = output.length;
      applyBlockSpacingAfter(output, margin);
      [output addAttribute:BlockquoteSpacerAttributeName value:@YES range:NSMakeRange(spacerLocation, 1)];
    }
  } else {
    applyBlockSpacingAfter(output, [_config blockquoteMarginBottom]);
  }
}

#pragma mark - Nested Blockquote Handling

- (NSArray<NSDictionary *> *)collectNestedBlockquotes:(NSMutableAttributedString *)output
                                                range:(NSRange)blockquoteRange
                                                depth:(NSInteger)currentDepth
{
  NSMutableArray<NSDictionary *> *nestedInfo = [NSMutableArray array];

  [output
      enumerateAttribute:BlockquoteDepthAttributeName
                 inRange:blockquoteRange
                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
              usingBlock:^(id value, NSRange range, BOOL *stop) {
                NSInteger depth = [value integerValue];
                if (value && depth > currentDepth) {
                  [nestedInfo
                      addObject:@{kNestedInfoDepthKey : value, kNestedInfoRangeKey : [NSValue valueWithRange:range]}];
                }
              }];

  return nestedInfo;
}

- (void)applyBaseBlockquoteStyle:(NSMutableAttributedString *)output
                        boxRange:(NSRange)boxRange
                      innerRange:(NSRange)innerRange
                           depth:(NSInteger)currentDepth
                    levelSpacing:(CGFloat)levelSpacing
                 backgroundColor:(RCTUIColor *)backgroundColor
                      lineHeight:(CGFloat)lineHeight
{
  CGFloat totalIndent = blockquoteIndentForDepth(currentDepth + 1, levelSpacing);
  CGFloat padding = [_config blockquotePadding];

  // Depth and background cover the whole box (incl. padding spacers) so the
  // border and background render behind list content and the padding rows.
  NSMutableDictionary *depthAttributes =
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@(currentDepth), BlockquoteDepthAttributeName, nil];
  if (backgroundColor) {
    depthAttributes[BlockquoteBackgroundColorAttributeName] = backgroundColor;
  }
  [output addAttributes:depthAttributes range:boxRange];

  // List items bake the blockquote indent into their own paragraph style; only non-list content is stamped here.
  [self enumerateNonListRangesIn:output
                           range:innerRange
                      usingBlock:^(NSRange nonListRange) {
                        NSMutableParagraphStyle *paragraphStyle =
                            getOrCreateParagraphStyle(output, nonListRange.location);
                        paragraphStyle.firstLineHeadIndent = totalIndent;
                        paragraphStyle.headIndent = totalIndent;
                        if (padding > 0) {
                          paragraphStyle.tailIndent = -padding;
                        }
                        [output addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:nonListRange];
                        applyLineHeight(output, nonListRange, lineHeight);
                        applyBaselineOffset(output, nonListRange);
                      }];

  if (padding > 0) {
    [self applyTailIndent:-padding toListRangesIn:output range:innerRange];
  }
}

- (void)applyTailIndent:(CGFloat)tailIndent toListRangesIn:(NSMutableAttributedString *)output range:(NSRange)range
{
  [output enumerateAttribute:ListDepthAttribute
                     inRange:range
                     options:0
                  usingBlock:^(id value, NSRange listRange, BOOL *stop) {
                    if (!value) {
                      return;
                    }
                    [output enumerateAttribute:NSParagraphStyleAttributeName
                                       inRange:listRange
                                       options:0
                                    usingBlock:^(NSParagraphStyle *style, NSRange styleRange, BOOL *innerStop) {
                                      NSMutableParagraphStyle *mutableStyle =
                                          style ? [style mutableCopy] : [[NSMutableParagraphStyle alloc] init];
                                      mutableStyle.tailIndent = tailIndent;
                                      [output addAttribute:NSParagraphStyleAttributeName
                                                     value:mutableStyle
                                                     range:styleRange];
                                    }];
                  }];
}

- (void)reapplyNestedStyles:(NSMutableAttributedString *)output
                 nestedInfo:(NSArray<NSDictionary *> *)nestedInfo
               levelSpacing:(CGFloat)levelSpacing
{
  // Re-apply indentation to nested blockquotes since applyBaseBlockquoteStyle
  // overwrote them with the parent's indentation
  CGFloat padding = [_config blockquotePadding];
  for (NSDictionary *info in nestedInfo) {
    NSRange nestedRange = [info[kNestedInfoRangeKey] rangeValue];
    NSInteger nestedDepth = [info[kNestedInfoDepthKey] integerValue];
    CGFloat indent = blockquoteIndentForDepth(nestedDepth + 1, levelSpacing);

    [output addAttribute:BlockquoteDepthAttributeName value:info[kNestedInfoDepthKey] range:nestedRange];

    [self enumerateNonListRangesIn:output
                             range:nestedRange
                        usingBlock:^(NSRange nonListRange) {
                          NSMutableParagraphStyle *style = getOrCreateParagraphStyle(output, nonListRange.location);
                          style.firstLineHeadIndent = indent;
                          style.headIndent = indent;
                          style.tailIndent = padding > 0 ? -padding : 0;
                          [output addAttribute:NSParagraphStyleAttributeName value:style range:nonListRange];
                        }];
  }
}

- (void)enumerateNonListRangesIn:(NSMutableAttributedString *)output
                           range:(NSRange)range
                      usingBlock:(void (^)(NSRange nonListRange))block
{
  // List items — and code blocks nested inside them (which carry a list-derived
  // indent instead of ListDepthAttribute) — already bake the correct indent in.
  NSMutableArray<NSValue *> *listRanges = [NSMutableArray array];
  void (^collectRanges)(NSString *) = ^(NSString *attribute) {
    [output enumerateAttribute:attribute
                       inRange:range
                       options:0
                    usingBlock:^(id value, NSRange subRange, BOOL *stop) {
                      if (value) {
                        [listRanges addObject:[NSValue valueWithRange:subRange]];
                      }
                    }];
  };
  collectRanges(ListDepthAttribute);
  collectRanges(CodeBlockIndentAttributeName);
  collectRanges(BlockquoteSpacerAttributeName);
  [listRanges sortUsingComparator:^NSComparisonResult(NSValue *a, NSValue *b) {
    NSUInteger la = [a rangeValue].location;
    NSUInteger lb = [b rangeValue].location;
    return la < lb ? NSOrderedAscending : (la > lb ? NSOrderedDescending : NSOrderedSame);
  }];

  NSUInteger pos = range.location;
  const NSUInteger end = NSMaxRange(range);
  for (NSValue *val in listRanges) {
    NSRange listRange = [val rangeValue];
    if (pos < listRange.location) {
      block(NSMakeRange(pos, listRange.location - pos));
    }
    pos = MAX(pos, NSMaxRange(listRange));
  }
  if (pos < end) {
    block(NSMakeRange(pos, end - pos));
  }
}

@end
