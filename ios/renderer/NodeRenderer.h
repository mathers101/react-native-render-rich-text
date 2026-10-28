#import <Foundation/Foundation.h>

@class TiptapASTNode;
@class RenderContext;

@protocol NodeRenderer <NSObject>
- (void)renderNode:(TiptapASTNode *)node into:(NSMutableAttributedString *)output context:(RenderContext *)context;
@end
