#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ENRMSpoilerOverlayMode) {
  ENRMSpoilerOverlayModeNone = 0,
};

ENRMSpoilerOverlayMode ENRMSpoilerOverlayFromString(NSString *mode);

@interface ENRMSpoilerOverlayManager : NSObject
@property (nonatomic, assign) ENRMSpoilerOverlayMode spoilerOverlay;
- (instancetype)initWithTextView:(id)textView config:(id)config;
- (void)setNeedsUpdate;
- (void)updateIfNeeded;
- (void)removeAllOverlays;
@end
