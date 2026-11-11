#pragma once
#import "ENRMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

@class StyleConfig;

@interface TextViewLayoutManager : NSLayoutManager

@property (nonatomic, strong) StyleConfig *config;

/// Character range of the factoid or mention chip darkened while a finger is down.
/// Location is NSNotFound when nothing is pressed. Stored as an associated object:
/// this class is swapped onto an existing NSLayoutManager, which has no room for a new ivar.
@property (nonatomic) NSRange pressedChipRange;
/// YES when `pressedChipRange` is a mention. A factoid otherwise.
@property (nonatomic) BOOL pressedChipIsMention;

- (BOOL)chipRangeIsPressed:(NSRange)range mention:(BOOL)mention;

@end

NS_ASSUME_NONNULL_END
