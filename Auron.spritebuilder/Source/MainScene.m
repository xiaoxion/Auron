#import "MainScene.h"

@implementation MainScene

- (void)onPlay {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

- (void)onTutorial {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

- (void)onCredits {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"CreditScene"]];
}

@end
