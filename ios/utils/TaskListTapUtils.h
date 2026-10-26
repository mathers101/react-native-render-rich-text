#import <Foundation/Foundation.h>

// Task lists are not rendered. The tap handler always misses.
BOOL handleTaskListTapWithSharedLogic(id textView, id recognizer, NSString *__strong *cachedMarkdown, id config,
                                      void (^onPress)(NSInteger index, BOOL checked, NSString *itemText),
                                      void (^onUpdate)(NSString *updatedMarkdown));
