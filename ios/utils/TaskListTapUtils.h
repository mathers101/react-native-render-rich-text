#import <Foundation/Foundation.h>

// Task lists are not rendered. The tap handler always misses.
// The implementation is Objective-C, and EnrichedTiptapText.mm calls it from C++.
#ifdef __cplusplus
extern "C" {
#endif

BOOL handleTaskListTapWithSharedLogic(id textView, id recognizer, NSString *__strong *cachedTiptap, id config,
                                      void (^onPress)(NSInteger index, BOOL checked, NSString *itemText),
                                      void (^onUpdate)(NSString *updatedTiptap));

#ifdef __cplusplus
}
#endif
