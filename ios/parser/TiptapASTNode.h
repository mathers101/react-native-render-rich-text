#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TiptapNodeType) {
  TiptapNodeTypeDocument,
  TiptapNodeTypeParagraph,
  TiptapNodeTypeText,
  TiptapNodeTypeLink,
  TiptapNodeTypeHeading,
  TiptapNodeTypeLineBreak,
  TiptapNodeTypeStrong,
  TiptapNodeTypeEmphasis,
  TiptapNodeTypeStrikethrough,
  TiptapNodeTypeUnderline,
  TiptapNodeTypeCode,
  TiptapNodeTypeImage,
  TiptapNodeTypeBlockquote,
  TiptapNodeTypeUnorderedList,
  TiptapNodeTypeOrderedList,
  TiptapNodeTypeListItem,
  TiptapNodeTypeCodeBlock,
  TiptapNodeTypeThematicBreak,
  TiptapNodeTypeTable,
  TiptapNodeTypeTableHead,
  TiptapNodeTypeTableBody,
  TiptapNodeTypeTableRow,
  TiptapNodeTypeTableHeaderCell,
  TiptapNodeTypeTableCell,
  TiptapNodeTypeLatexMathInline,
  TiptapNodeTypeLatexMathDisplay,
  TiptapNodeTypeSpoiler,
  TiptapNodeTypeSuperscript,
  TiptapNodeTypeSubscript,
  TiptapNodeTypeHighlight,
  TiptapNodeTypeSoftBreak,
  TiptapNodeTypeBlankLine,
  TiptapNodeTypeAdmonition,
  TiptapNodeTypeVideo,
  TiptapNodeTypeFactoid
};

@interface TiptapASTNode : NSObject

@property (nonatomic, assign) TiptapNodeType type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSMutableArray<TiptapASTNode *> *children;

- (instancetype)initWithType:(TiptapNodeType)type;
- (void)addChild:(TiptapASTNode *)child;
- (void)setAttribute:(NSString *)key value:(NSString *)value;

@end

/// A node type that md4c emits as a standalone block stacked vertically,
/// as opposed to an inline span.
BOOL ENRMIsTopLevelBlockType(TiptapNodeType type);
