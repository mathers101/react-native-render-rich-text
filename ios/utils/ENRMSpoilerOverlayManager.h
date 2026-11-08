#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ENRMSpoilerOverlayMode) {
  ENRMSpoilerOverlayModeNone = 0,
};

#ifdef __cplusplus
extern "C" {
#endif

ENRMSpoilerOverlayMode ENRMSpoilerOverlayFromString(NSString *mode);

#ifdef __cplusplus
}
#endif

@interface ENRMSpoilerOverlayManager : NSObject
@property (nonatomic, assign) ENRMSpoilerOverlayMode spoilerOverlay;
- (instancetype)initWithTextView:(id)textView config:(id)config;
- (void)setNeedsUpdate;
- (void)updateIfNeeded;
- (void)removeAllOverlays;
@end
