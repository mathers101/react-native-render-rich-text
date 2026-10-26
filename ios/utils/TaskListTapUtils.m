#import "TaskListTapUtils.h"

BOOL handleTaskListTapWithSharedLogic(id textView, id recognizer, NSString *__strong *cachedMarkdown, id config,
                                      void (^onPress)(NSInteger index, BOOL checked, NSString *itemText),
                                      void (^onUpdate)(NSString *updatedMarkdown))
{
  (void)textView;
  (void)recognizer;
  (void)cachedMarkdown;
  (void)config;
  (void)onPress;
  (void)onUpdate;
  return NO;
}
