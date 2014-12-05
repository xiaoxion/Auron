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

// Initialization and Loading of assets.
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _slime.physicsBody.collisionType = @"slime";
    _auron.physicsBody.collisionType = @"hero";
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"Jump.mp3"];
    [audio preloadEffect:@"Jab.mp3"];
}

// Moves player and Slime
- (void)update:(CCTime)delta {
    _auron.position = ccp(_auron.position.x + delta * speed, _auron.position.y);
    _slime.position = ccp(_slime.position.x - delta * speed, _slime.position.y);
}

// Checks when jump begins and limits jump height.
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    startTime = [NSDate date];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval deltaTime = [nowTime timeIntervalSinceDate:startTime];
    
    if (deltaTime < .5) {
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        if (jumped) {
            [_auron.physicsBody applyImpulse:ccp(0, 250.0f)];
        } else {
            jumped = true;
            [_auron.physicsBody applyImpulse:ccp(0, 1000.0f)];
        }
        [audio playEffect:@"Jump.mp3"];
    }
}

// Checks collision and elimnates player if they touch the slime
- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA slime:(CCNode *)nodeB {
    [_auron.physicsBody applyImpulse:ccp(0, 100.f) atWorldPoint:ccp(0, 100.f)];
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"Jab.mp3"];
}

@end