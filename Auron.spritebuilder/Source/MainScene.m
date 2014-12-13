#import "MainScene.h"

@implementation MainScene

bool paused = false;
static MainScene *_instance = nil;

+ (MainScene *)instance {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    
    return _instance;
}

-(void)onPause {
    if (paused) {
        _levelZero.paused = false;
        _levelZero.userInteractionEnabled = YES;
        paused = false;
    } else {
        _levelZero.paused = true;
        _levelZero.userInteractionEnabled = NO;
        paused = true;
    }
}

- (void)removeHeart:(int)hitCount {
    if (hitCount == 1) {
        _heartTwo.visible = false;
    } else if (hitCount == 2) {
        _heartOne.visible = false;
    } else if (hitCount == 3) {
        _levelZero.paused = true;
        _levelZero.userInteractionEnabled = NO;
    }
}

@end
