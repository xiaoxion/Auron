#import "MainScene.h"

@implementation MainScene

bool paused = false;
static MainScene *_instance = nil;

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

@end
