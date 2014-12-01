//
//  LevelZero.m
//  Auron
//
//  Created by Esau Rubio on 11/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelZero.h"

static const CGFloat speed = 80.0f;

@implementation LevelZero
bool jumped = false;

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
}

- (void)update:(CCTime)delta {
    _auron.position = ccp(_auron.position.x + delta * speed, _auron.position.y);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    startTime = [NSDate date];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval deltaTime = [nowTime timeIntervalSinceDate:startTime];
    
    if (deltaTime > .05) {
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        if (!jumped) {
            [_auron.physicsBody applyImpulse:ccp(0, 1000.f)];
            [audio playEffect:@"Jump.mp3"];
            jumped = true;
        } else {
            [audio playEffect:@"Jab.mp3"];
        }
    }
}

@end