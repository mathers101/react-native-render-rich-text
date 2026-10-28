#import "TiptapASTNode.h"

@implementation TiptapASTNode

- (instancetype)initWithType:(TiptapNodeType)type
{
  if (self = [super init]) {
    _type = type;
    _content = nil;
    _attributes = [[NSMutableDictionary alloc] init];
    _children = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)addChild:(TiptapASTNode *)child
{
  [_children addObject:child];
}

- (void)setAttribute:(NSString *)key value:(NSString *)value
{
  _attributes[key] = value;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"TiptapASTNode(type=%ld, content=%@, children=%lu)", (long)_type, _content,
                                    (unsigned long)_children.count];
}

@end

BOOL ENRMIsTopLevelBlockType(TiptapNodeType type)
{
  switch (type) {
    case TiptapNodeTypeParagraph:
    case TiptapNodeTypeHeading:
    case TiptapNodeTypeCodeBlock:
    case TiptapNodeTypeBlockquote:
    case TiptapNodeTypeAdmonition:
    case TiptapNodeTypeTable:
    case TiptapNodeTypeUnorderedList:
    case TiptapNodeTypeOrderedList:
    case TiptapNodeTypeThematicBreak:
    case TiptapNodeTypeBlankLine:
    case TiptapNodeTypeLatexMathDisplay:
      return YES;
    default:
      return NO;
  }
}
