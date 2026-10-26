#import <Foundation/Foundation.h>

// Spoilers are not rendered. The attribute name stays so link hit-testing compiles.
extern NSString *const SpoilerAttributeName;

BOOL handleSpoilerTap(id textView, id recognizer, id manager);
