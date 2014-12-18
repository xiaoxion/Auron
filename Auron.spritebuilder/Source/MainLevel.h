#import "LevelZero.h"

@interface MainLevel : CCNode <RemoveHeartDelegate>
{
    CCScrollView* _levelZeroView;
    CCButton* _replayButton;
    CCNode* _heartOne;
    CCNode* _heartTwo;
    CCNode* _tutorial;
}

@end
