//
//  MainLevel.m
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainLevel.h"

@implementation MainLevel

- (void)didLoadFromCCB {
    self.userInteractionEnabled = true;
    _replayButton.visible = false;
}

- (void)update:(CCTime)delta {
    if (!_levelZeroView.paused) {
        _levelZeroView.scrollPosition = ccp(_levelZeroView.scrollPosition.x + delta * 80.0f, _levelZeroView.scrollPosition.y);
    }
}

- (void)onPause {
    if (_levelZeroView.paused) {
        _levelZeroView.paused = false;
        _levelZeroView.userInteractionEnabled = YES;
    } else {
        _levelZeroView.paused = true;
        _levelZeroView.userInteractionEnabled = NO;
    }
}

- (void)removeHeart:(int)hitCount{
    if (hitCount == 1) {
        _heartTwo.visible = false;
    } else if (hitCount == 2) {
        _heartOne.visible = false;
        _levelZeroView.paused = true;
        _levelZeroView.userInteractionEnabled = NO;
        _replayButton.visible = true;
    }
}

- (void)onReplay {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

@end
