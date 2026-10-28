#import "TiptapASTNode.h"
#import "NodeRenderer.h"

@class RenderContext;

@interface RendererFactory : NSObject
- (instancetype)initWithConfig:(id)config;
- (id<NodeRenderer>)rendererForNodeType:(TiptapNodeType)type;
- (void)renderChildrenOfNode:(TiptapASTNode *)node
                        into:(NSMutableAttributedString *)output
                     context:(RenderContext *)context;
@end
