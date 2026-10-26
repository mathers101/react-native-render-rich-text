#import "ENRMSpoilerOverlayManager.h"

ENRMSpoilerOverlayMode ENRMSpoilerOverlayFromString(NSString *mode)
{
  (void)mode;
  return ENRMSpoilerOverlayModeNone;
}

@implementation ENRMSpoilerOverlayManager
- (instancetype)initWithTextView:(id)textView config:(id)config
{
  (void)textView;
  (void)config;
  return [super init];
}
- (void)setNeedsUpdate {}
- (void)updateIfNeeded {}
- (void)removeAllOverlays {}
@end
