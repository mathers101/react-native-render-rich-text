#import <Foundation/Foundation.h>

// Spoilers are not rendered. The attribute name stays so link hit-testing compiles.
// The implementation is Objective-C, and EnrichedTiptapText.mm calls it from C++.
#ifdef __cplusplus
extern "C" {
#endif

extern NSString *const SpoilerAttributeName;

BOOL handleSpoilerTap(id textView, id recognizer, id manager);

#ifdef __cplusplus
}
#endif
