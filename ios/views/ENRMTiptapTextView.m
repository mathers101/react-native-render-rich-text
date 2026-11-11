#import "ENRMTiptapTextView.h"
#import "ENRMLinkPillAttachment.h"
#import "ENRMLinkPillText.h"
#import "ENRMTextHitTest.h"
#import "LinkTapUtils.h"
#import "PasteboardUtils.h"
#import "TextViewLayoutManager.h"

#if !TARGET_OS_OSX

/// Tracks a finger on a factoid or mention without taking the touch. A tap recognizer
/// delays the view's touch-up and then discards it when the tap succeeds, so the view
/// itself cannot be relied on to lift the darkening. This recognizer sees every phase,
/// and it neither cancels the touch nor prevents the tap, the mention hold, or a scroll.
@interface ENRMChipPressRecognizer : UIGestureRecognizer
@end

@implementation ENRMChipPressRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
  if (self = [super initWithTarget:target action:action]) {
    self.cancelsTouchesInView = NO;
    self.delaysTouchesBegan = NO;
    self.delaysTouchesEnded = NO;
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  if (touches.count != 1 || event.allTouches.count != 1) {
    // Failed is only valid from Possible. A second finger mid-press cancels instead.
    self.state = self.state == UIGestureRecognizerStatePossible ? UIGestureRecognizerStateFailed
                                                                : UIGestureRecognizerStateCancelled;
    return;
  }
  if (self.state == UIGestureRecognizerStatePossible)
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged)
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged)
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged)
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
  (void)preventedGestureRecognizer;
  return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
  (void)preventingGestureRecognizer;
  return NO;
}

@end

@interface ENRMTiptapTextView () <UIContextMenuInteractionDelegate>
- (BOOL)chipHitAtPoint:(CGPoint)point range:(NSRange *)range isMention:(BOOL *)isMention;
@end

/// Delegate is a separate object. UITextView is the delegate of its own gestures, and
/// overriding those methods here would change selection and link handling.
@interface ENRMChipPressDelegate : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, weak) ENRMTiptapTextView *textView;
@end

@implementation ENRMChipPressDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  (void)gestureRecognizer;
  return [self.textView chipHitAtPoint:[touch locationInView:self.textView] range:NULL isMention:NULL];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  (void)gestureRecognizer;
  (void)otherGestureRecognizer;
  return YES;
}

@end

@implementation ENRMTiptapTextView {
  ENRMLinkMenuLift *_pillLift;
  // The pill whose menu is being presented. It draws nothing for as long as its lifted image
  // stands in for it: it would show through that image.
  ENRMLinkPillAttachment *_liftedPill;
  NSUInteger _pillMenuIndex;
  // The chip the finger went down on. Sliding off it lifts the darkening; sliding back restores it.
  NSRange _trackedChipRange;
  BOOL _trackedChipIsMention;
  BOOL _chipPressed;
  ENRMChipPressDelegate *_chipPressDelegate;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
  if (self = [super initWithFrame:frame textContainer:textContainer]) {
    _trackedChipRange = NSMakeRange(NSNotFound, 0);
    _chipPressDelegate = [ENRMChipPressDelegate new];
    _chipPressDelegate.textView = self;
    ENRMChipPressRecognizer *chipPress = [[ENRMChipPressRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(chipPressRecognized:)];
    chipPress.delegate = _chipPressDelegate;
    [self addGestureRecognizer:chipPress];
    _pillLift = [[ENRMLinkMenuLift alloc] init];
    __weak ENRMTiptapTextView *weakSelf = self;
    _pillLift.onEnd = ^{ [weakSelf restoreLiftedPill]; };
    [self addInteraction:[[UIContextMenuInteraction alloc] initWithDelegate:self]];
  }
  return self;
}

/// A tap places the caret, and UITextView then scrolls that caret into view. This view is
/// already sized to its text and sits in the screen's scroll view, so that scroll shifts
/// the page and the tapped line jumps toward the top. Scrolling stays off, and these
/// requests are dropped. Copy and selection are unchanged.
- (void)setContentOffset:(CGPoint)contentOffset
{
  if (!self.scrollEnabled && !CGPointEqualToPoint(contentOffset, CGPointZero)) {
    if (!CGPointEqualToPoint(self.contentOffset, CGPointZero)) {
      [super setContentOffset:CGPointZero];
    }
    return;
  }
  [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
  if (!self.scrollEnabled) {
    [self setContentOffset:CGPointZero];
    return;
  }
  [super setContentOffset:contentOffset animated:animated];
}

- (void)scrollRangeToVisible:(NSRange)range
{
  if (self.scrollEnabled)
    [super scrollRangeToVisible:range];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
  if (self.scrollEnabled)
    [super scrollRectToVisible:rect animated:animated];
}

/// New text moves or replaces the pill under its lifted image.
- (void)setAttributedText:(NSAttributedString *)attributedText
{
  [self endChipPress];
  [_pillLift end];
  [super setAttributedText:attributedText];
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  if (self.window == nil)
    [self endChipPress];
}

#pragma mark - Chip press

- (void)chipPressRecognized:(UIGestureRecognizer *)recognizer
{
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:
      [self beginChipPressAtPoint:[recognizer locationInView:self]];
      break;
    case UIGestureRecognizerStateChanged:
      [self setChipPressed:[self pointHitsTrackedChip:[recognizer locationInView:self]]];
      break;
    default:
      [self endChipPress];
      break;
  }
}

/// Link wins, then a mention, then the factoid around it. That is the order a tap emits.
/// Either out-parameter may be NULL. Returns NO when this press should not darken a chip.
- (BOOL)chipHitAtPoint:(CGPoint)point range:(NSRange *)outRange isMention:(BOOL *)isMention
{
  if (outRange)
    *outRange = NSMakeRange(NSNotFound, 0);
  if (isMention)
    *isMention = NO;
  if (linkURLAtPoint(self, point) != nil)
    return NO;

  NSRange range = mentionRangeAtPoint(self, point);
  BOOL mention = range.location != NSNotFound;
  if (!mention)
    range = factoidRangeAtPoint(self, point);
  if (range.location == NSNotFound)
    return NO;
  if (outRange)
    *outRange = range;
  if (isMention)
    *isMention = mention;
  return YES;
}

- (void)beginChipPressAtPoint:(CGPoint)point
{
  NSRange range = NSMakeRange(NSNotFound, 0);
  BOOL isMention = NO;
  if (![self chipHitAtPoint:point range:&range isMention:&isMention])
    return;
  _trackedChipRange = range;
  _trackedChipIsMention = isMention;
  [self setChipPressed:YES];
}

- (BOOL)pointHitsTrackedChip:(CGPoint)point
{
  if (_trackedChipRange.location == NSNotFound)
    return NO;
  NSRange range = _trackedChipIsMention ? mentionRangeAtPoint(self, point) : factoidRangeAtPoint(self, point);
  return NSEqualRanges(range, _trackedChipRange);
}

- (void)setChipPressed:(BOOL)pressed
{
  if (_chipPressed == pressed)
    return;
  _chipPressed = pressed;

  NSLayoutManager *layoutManager = self.layoutManager;
  if ([layoutManager isKindOfClass:[TextViewLayoutManager class]]) {
    TextViewLayoutManager *manager = (TextViewLayoutManager *)layoutManager;
    if (pressed) {
      manager.pressedChipIsMention = _trackedChipIsMention;
      manager.pressedChipRange = _trackedChipRange;
    } else {
      manager.pressedChipRange = NSMakeRange(NSNotFound, 0);
    }
    NSTextStorage *storage = self.textStorage;
    if (_trackedChipRange.location != NSNotFound && NSMaxRange(_trackedChipRange) <= storage.length)
      [manager invalidateDisplayForCharacterRange:_trackedChipRange];
  }
  [self setNeedsDisplay];
}

- (void)endChipPress
{
  [self setChipPressed:NO];
  _trackedChipRange = NSMakeRange(NSNotFound, 0);
}

/// The selection with pills expanded, or nil when `range` is not the selection or holds no pill.
/// Only the selection is rewritten: UIKit also reads arbitrary ranges to find word boundaries,
/// and those must keep matching storage offsets.
- (nullable NSAttributedString *)expandedSelectionForRange:(UITextRange *)range
{
  UITextRange *selection = self.selectedTextRange;
  if (!range || !selection || selection.isEmpty || ![range isEqual:selection])
    return nil;
  NSRange selected = self.selectedRange;
  NSTextStorage *storage = self.textStorage;
  if (selected.location == NSNotFound || NSMaxRange(selected) > storage.length)
    return nil;
  NSAttributedString *text = [storage attributedSubstringFromRange:selected];
  NSAttributedString *expanded = ENRMAttributedStringByExpandingLinkPills(text, NULL);
  return expanded == text ? nil : expanded;
}

- (NSString *)textInRange:(UITextRange *)range
{
  return [self expandedSelectionForRange:range].string ?: [super textInRange:range];
}

- (NSAttributedString *)attributedTextInRange:(UITextRange *)range
{
  return [self expandedSelectionForRange:range] ?: [super attributedTextInRange:range];
}

/// The menu's Copy is already replaced by the library's own action; this covers the key command.
- (void)copy:(id)sender
{
  NSRange selected = self.selectedRange;
  if (self.copySelectionHandler && selected.location != NSNotFound && selected.length > 0) {
    self.copySelectionHandler(selected);
    return;
  }
  NSAttributedString *expanded = [self expandedSelectionForRange:self.selectedTextRange];
  if (!expanded) {
    [super copy:sender];
    return;
  }
  copyAttributedStringToPasteboard(expanded, nil, nil);
}

#pragma mark - Pill menus

- (nullable ENRMLinkContextMenus *)linkContextMenus
{
  id delegate = self.delegate;
  return [delegate conformsToProtocol:@protocol(ENRMLinkContextMenuSource)]
             ? [(id<ENRMLinkContextMenuSource>)delegate linkContextMenusForTextView:self]
             : nil;
}

/// Where the pill at `index` is drawn, in the text view's coordinates.
- (CGRect)pillFrameAtIndex:(NSUInteger)index
{
  NSLayoutManager *layoutManager = self.layoutManager;
  NSUInteger glyph = [layoutManager glyphIndexForCharacterAtIndex:index];
  CGSize size = [layoutManager attachmentSizeForGlyphAtIndex:glyph];
  if (size.width <= 0 || size.height <= 0)
    return CGRectNull;
  CGRect line = [layoutManager lineFragmentRectForGlyphAtIndex:glyph effectiveRange:NULL];
  // TextKit places an attachment glyph at the bottom edge of its bounds.
  CGPoint location = [layoutManager locationForGlyphAtIndex:glyph];
  UIEdgeInsets inset = self.textContainerInset;
  return CGRectMake(inset.left + line.origin.x + location.x, inset.top + line.origin.y + location.y - size.height,
                    size.width, size.height);
}

/// Whether the character at `index` is a pill whose link has a menu.
- (BOOL)presentsLinkMenuAtIndex:(NSUInteger)index
{
  ENRMLinkContextMenus *menus = [self linkContextMenus];
  NSTextStorage *storage = self.textStorage;
  if (menus.entries.count == 0 || index >= storage.length)
    return NO;
  id attachment = [storage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:NULL];
  return [attachment isKindOfClass:ENRMLinkPillAttachment.class] &&
         [menus hasMenuForURL:linkURLAtRange(self, NSMakeRange(index, 1))];
}

/// The character index of the pill under `point` when its link has a menu, else NSNotFound.
- (NSUInteger)menuPillIndexAtPoint:(CGPoint)point
{
  if ([self linkContextMenus].entries.count == 0)
    return NSNotFound;
  NSUInteger index = ENRMCharacterIndexAtPoint(self, point);
  if (index == NSNotFound || ![self presentsLinkMenuAtIndex:index] ||
      !CGRectContainsPoint([self pillFrameAtIndex:index], point))
    return NSNotFound;
  return index;
}

- (void)setPill:(ENRMLinkPillAttachment *)pill lifted:(BOOL)lifted
{
  pill.lifted = lifted;
  NSTextStorage *storage = self.textStorage;
  [storage enumerateAttribute:NSAttachmentAttributeName
                      inRange:NSMakeRange(0, storage.length)
                      options:0
                   usingBlock:^(id value, NSRange range, BOOL *stop) {
                     if (value != pill)
                       return;
                     [self.layoutManager invalidateDisplayForCharacterRange:range];
                     *stop = YES;
                   }];
}

- (void)restoreLiftedPill
{
  if (_liftedPill)
    [self setPill:_liftedPill lifted:NO];
  _liftedPill = nil;
}

- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                        configurationForMenuAtLocation:(CGPoint)location
{
  [_pillLift end];
  _pillMenuIndex = [self menuPillIndexAtPoint:location];
  if (_pillMenuIndex == NSNotFound)
    return nil;
  UIMenu *menu = [[self linkContextMenus] menuForURL:linkURLAtRange(self, NSMakeRange(_pillMenuIndex, 1))
                                               title:linkTitleAtIndex(self.textStorage, _pillMenuIndex)];
  if (!menu)
    return nil;
  return [UIContextMenuConfiguration
      configurationWithIdentifier:nil
                  previewProvider:nil
                   actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) { return menu; }];
}

/// The pill is lifted as an image of itself, see `ENRMLinkMenuLift`.
- (UITargetedPreview *)pillMenuPreview
{
  if (![_pillLift isOverView:self]) {
    NSTextStorage *storage = self.textStorage;
    if (self.window == nil || _pillMenuIndex >= storage.length)
      return nil;
    id attachment = [storage attribute:NSAttachmentAttributeName atIndex:_pillMenuIndex effectiveRange:NULL];
    CGRect frame = [self pillFrameAtIndex:_pillMenuIndex];
    if (![attachment isKindOfClass:ENRMLinkPillAttachment.class] || CGRectIsNull(frame))
      return nil;
    UIImage *image = [(ENRMLinkPillAttachment *)attachment imageForBounds:(CGRect){CGPointZero, frame.size}
                                                            textContainer:self.textContainer
                                                           characterIndex:_pillMenuIndex];
    [_pillLift layImage:image atFrame:frame overView:self];
    _liftedPill = attachment;
    [self setPill:_liftedPill lifted:YES];
  }
  return [_pillLift previewWithCornerRadius:_liftedPill.cornerRadius backgroundColor:UIColor.clearColor];
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
    previewForHighlightingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration
{
  return [self pillMenuPreview];
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
    previewForDismissingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration
{
  return [self pillMenuPreview];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction
       willEndForConfiguration:(UIContextMenuConfiguration *)configuration
                      animator:(id<UIContextMenuInteractionAnimating>)animator
{
  [_pillLift endWithAnimator:animator];
}

@end
#endif
