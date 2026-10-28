#import "ENRMTiptapParser.h"
#import "ENRMLinkRegexConfig.h"
#import "TiptapASTNode.h"

extern TiptapASTNode *parseTiptapWithCppParser(NSString *tiptap, ENRMMd4cFlags *flags, BOOL isGFM);
extern TiptapASTNode *parseTiptapWithCppParser(NSString *tiptap, ENRMMd4cFlags *flags, BOOL isGFM,
                                                   ENRMLinkRegexConfig *textRegex, ENRMLinkRegexConfig *codeRegex);

@implementation ENRMMd4cFlags

- (instancetype)init
{
  if (self = [super init]) {
    _underline = NO;
    _latexMath = YES;
    _superscript = NO;
    _subscript = NO;
    _highlight = NO;
    _hardSoftBreaks = NO;
    _preserveBlankLines = NO;
    _admonitions = YES;
  }
  return self;
}

+ (instancetype)defaultFlags
{
  return [[ENRMMd4cFlags alloc] init];
}

- (id)copyWithZone:(NSZone *)zone
{
  ENRMMd4cFlags *copy = [[ENRMMd4cFlags allocWithZone:zone] init];
  copy.underline = self.underline;
  copy.latexMath = self.latexMath;
  copy.superscript = self.superscript;
  copy.subscript = self.subscript;
  copy.highlight = self.highlight;
  copy.hardSoftBreaks = self.hardSoftBreaks;
  copy.preserveBlankLines = self.preserveBlankLines;
  copy.admonitions = self.admonitions;
  return copy;
}

@end

@implementation ENRMTiptapParser

- (TiptapASTNode *)parseTiptap:(NSString *)tiptap
{
  return [self parseTiptap:tiptap flags:[ENRMMd4cFlags defaultFlags]];
}

- (TiptapASTNode *)parseTiptap:(NSString *)tiptap flags:(ENRMMd4cFlags *)flags
{
  return [self parseTiptap:tiptap flags:flags isGFM:YES];
}

- (TiptapASTNode *)parseTiptap:(NSString *)tiptap flags:(ENRMMd4cFlags *)flags isGFM:(BOOL)isGFM
{
  return parseTiptapWithCppParser(tiptap, flags, isGFM);
}

- (TiptapASTNode *)parseTiptap:(NSString *)tiptap
                             flags:(ENRMMd4cFlags *)flags
                             isGFM:(BOOL)isGFM
                         linkRegex:(ENRMLinkRegexConfig *)linkRegex
               inlineCodeLinkRegex:(ENRMLinkRegexConfig *)inlineCodeLinkRegex
{
  return parseTiptapWithCppParser(tiptap, flags, isGFM, linkRegex, inlineCodeLinkRegex);
}

@end
