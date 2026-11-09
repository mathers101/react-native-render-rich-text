#import "LinkTapUtils.h"
#import "ENRMLinkPillAttachment.h"
#import "ENRMSpoilerTapUtils.h"
#import "ENRMTextHitTest.h"
#import "FactoidBackground.h"
#import "MentionBackground.h"

NSString *_Nullable linkURLAtTapLocation(ENRMPlatformTextView *textView, ENRMTapRecognizer *recognizer)
{
  NSUInteger characterIndex = ENRMCharacterIndexForTap(textView, recognizer);
  if (characterIndex == NSNotFound)
    return nil;

  NSAttributedString *attrText = ENRMGetAttributedText(textView);
  return [attrText attribute:@"linkURL" atIndex:characterIndex effectiveRange:NULL];
}

NSString *_Nullable linkURLAtPoint(ENRMPlatformTextView *textView, CGPoint point)
{
  NSUInteger index = ENRMCharacterIndexAtPoint(textView, point);
  if (index == NSNotFound)
    return nil;
  return [ENRMGetAttributedText(textView) attribute:@"linkURL" atIndex:index effectiveRange:NULL];
}

NSString *_Nullable linkURLAtRange(ENRMPlatformTextView *textView, NSRange characterRange)
{
  NSAttributedString *attrText = ENRMGetAttributedText(textView);
  if (characterRange.location >= attrText.length) {
    return nil;
  }
  return [attrText attribute:@"linkURL" atIndex:characterRange.location effectiveRange:NULL];
}

NSString *_Nullable linkTitleAtIndex(NSAttributedString *text, NSUInteger index)
{
  if (index >= text.length)
    return nil;
#if !TARGET_OS_OSX
  id attachment = [text attribute:NSAttachmentAttributeName atIndex:index effectiveRange:NULL];
  if ([attachment isKindOfClass:ENRMLinkPillAttachment.class])
    return ((ENRMLinkPillAttachment *)attachment).label;
#endif
  NSRange range;
  id url = [text attribute:@"linkURL" atIndex:index longestEffectiveRange:&range inRange:NSMakeRange(0, text.length)];
  return url ? [text.string substringWithRange:range] : nil;
}

NSDictionary<NSString *, NSString *> *_Nullable imageAtTapLocation(ENRMPlatformTextView *textView,
                                                                   ENRMTapRecognizer *recognizer)
{
  NSUInteger characterIndex = ENRMCharacterIndexForTap(textView, recognizer);
  if (characterIndex == NSNotFound)
    return nil;

  NSAttributedString *attrText = ENRMGetAttributedText(textView);
  if ([attrText attribute:@"linkURL" atIndex:characterIndex effectiveRange:NULL] != nil)
    return nil;

  NSString *url = [attrText attribute:@"imageURL" atIndex:characterIndex effectiveRange:NULL];
  if (!url)
    return nil;

  NSString *altText = [attrText attribute:@"imageAltText" atIndex:characterIndex effectiveRange:NULL];
  return @{@"url" : url, @"altText" : altText ?: @""};
}

static NSDictionary<NSString *, NSString *> *_Nullable mentionAtIndex(NSAttributedString *attrText, NSUInteger characterIndex)
{
  if (characterIndex == NSNotFound || characterIndex >= attrText.length)
    return nil;
  if ([attrText attribute:MentionAttributeName atIndex:characterIndex effectiveRange:NULL] == nil)
    return nil;

  NSString *mentionId = [attrText attribute:MentionIdAttributeName atIndex:characterIndex effectiveRange:NULL] ?: @"";
  NSString *label = [attrText attribute:MentionLabelAttributeName atIndex:characterIndex effectiveRange:NULL] ?: @"";
  return @{@"id" : mentionId, @"label" : label};
}

NSDictionary<NSString *, NSString *> *_Nullable mentionAtTapLocation(ENRMPlatformTextView *textView,
                                                                     ENRMTapRecognizer *recognizer)
{
  return mentionAtIndex(ENRMGetAttributedText(textView), ENRMCharacterIndexForTap(textView, recognizer));
}

NSDictionary<NSString *, NSString *> *_Nullable mentionAtPoint(ENRMPlatformTextView *textView, CGPoint point)
{
  return mentionAtIndex(ENRMGetAttributedText(textView), ENRMCharacterIndexAtPoint(textView, point));
}

static NSString *_Nullable factoidIdAtIndex(NSAttributedString *attrText, NSUInteger characterIndex)
{
  if (characterIndex == NSNotFound || characterIndex >= attrText.length)
    return nil;
  if ([attrText attribute:FactoidAttributeName atIndex:characterIndex effectiveRange:NULL] == nil)
    return nil;
  return [attrText attribute:FactoidIdAttributeName atIndex:characterIndex effectiveRange:NULL] ?: @"";
}

/// The green box is the full line height and a hair wider than the glyphs. A tap on that box
/// can miss the character index, so the drawn rect is the hit target.
static NSString *_Nullable factoidIdInDrawnRect(ENRMPlatformTextView *textView, CGPoint point)
{
  NSLayoutManager *layoutManager = textView.layoutManager;
  NSTextStorage *storage = layoutManager.textStorage;
  if (!storage || storage.length == 0)
      return nil;

  CGPoint adjusted = CGPointMake(point.x - textView.textContainerInset.left, point.y - textView.textContainerInset.top);
#if !TARGET_OS_OSX
  adjusted.x += textView.contentOffset.x;
  adjusted.y += textView.contentOffset.y;
#endif

  __block NSString *found = nil;
  [storage enumerateAttribute:FactoidAttributeName
                      inRange:NSMakeRange(0, storage.length)
                      options:0
                   usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (found || !value || range.length == 0)
                       return;
                     NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
                     if (glyphRange.location == NSNotFound || glyphRange.length == 0)
                       return;
                     [layoutManager
                         enumerateLineFragmentsForGlyphRange:glyphRange
                                                  usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *container,
                                                               NSRange lineRange, BOOL *stopLine) {
                                                    (void)usedRect;
                                                    (void)container;
                                                    NSRange intersect = NSIntersectionRange(lineRange, glyphRange);
                                                    if (intersect.length == 0)
                                                      return;
                                                    CGRect textRect = [layoutManager boundingRectForGlyphRange:intersect
                                                                                               inTextContainer:textView.textContainer];
                                                    CGRect hitRect = CGRectInset(CGRectMake(textRect.origin.x, rect.origin.y,
                                                                                            textRect.size.width, rect.size.height),
                                                                                 -1, -1);
                                                    if (!CGRectContainsPoint(hitRect, adjusted))
                                                      return;
                                                       found = [storage attribute:FactoidIdAttributeName
                                                                       atIndex:range.location
                                                                effectiveRange:NULL] ?:
                                                            @"";
                                                    *stopLine = YES;
                                                  }];
                     if (found)
                       *stop = YES;
                   }];
  return found;
}

NSString *_Nullable factoidIdAtTapLocation(ENRMPlatformTextView *textView, ENRMTapRecognizer *recognizer)
{
  CGPoint point = [recognizer locationInView:textView];
  NSString *byIndex = factoidIdAtIndex(ENRMGetAttributedText(textView), ENRMCharacterIndexAtPoint(textView, point));
  return byIndex ?: factoidIdInDrawnRect(textView, point);
}

NSDictionary<NSString *, NSString *> *_Nullable codeBlockAtTapLocation(ENRMPlatformTextView *textView,
                                                                       ENRMTapRecognizer *recognizer)
{
  NSUInteger characterIndex = ENRMCharacterIndexForTap(textView, recognizer);
  if (characterIndex == NSNotFound)
    return nil;

  NSAttributedString *attrText = ENRMGetAttributedText(textView);
  NSString *code = [attrText attribute:@"codeBlockText" atIndex:characterIndex effectiveRange:NULL];
  if (!code)
    return nil;

  NSString *language = [attrText attribute:@"codeBlockLanguage" atIndex:characterIndex effectiveRange:NULL];
  return @{@"code" : code, @"language" : language ?: @""};
}

BOOL isPointOnInteractiveElement(ENRMPlatformTextView *textView, CGPoint point, BOOL includeImages,
                                 BOOL includeCodeBlock)
{
    return YES;

  NSUInteger charIndex = ENRMCharacterIndexAtPoint(textView, point);
  if (charIndex == NSNotFound)
    return NO;

  NSDictionary *attrs = [ENRMGetAttributedText(textView) attributesAtIndex:charIndex effectiveRange:NULL];
  if (attrs[@"linkURL"] != nil || [attrs[@"TaskItem"] boolValue] || attrs[SpoilerAttributeName] != nil ||
      attrs[FactoidAttributeName] != nil || attrs[MentionAttributeName] != nil)
    return YES;

  if (includeImages && attrs[@"imageURL"] != nil)
    return YES;

  return includeCodeBlock && attrs[@"codeBlockText"] != nil;
}
