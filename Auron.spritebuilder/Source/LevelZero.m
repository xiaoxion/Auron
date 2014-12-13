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

NSDate* startJump;
NSDate* startSound;
int hitCount = 0;
bool jumped = false;
bool doubleJump = false;

// Initialization and Loading of assets.
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _slime.physicsBody.collisionType = @"slime";
    _auron.physicsBody.collisionType = @"hero";
    _ground.physicsBody.collisionType = @"ground";
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"Jump.mp3"];
    [audio preloadEffect:@"Jab.mp3"];
}

// Moves player and Slime
- (void)update:(CCTime)delta {
    if (_auron.position.x < 1130.0f) {
        _auron.position = ccp(_auron.position.x + delta * speed, _auron.position.y);
    }
    _slime.position = ccp(_slime.position.x - delta * speed, _slime.position.y);
}

// Checks when jump begins and limits jump height.
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    startJump = [NSDate date];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval deltaTime = [nowTime timeIntervalSinceDate:startJump];
    
    // If acceptable tap, auron will jump.
    if (deltaTime < .5) {
        // Checks if user has jumped previously
        if (jumped) {
            //Checks if user gets a smaller double jump
            if (doubleJump) {
                return;
            } else {
                doubleJump = true;
                [_auron.physicsBody applyImpulse:ccp(0, 550.0f)];
            }
        } else {
            jumped = true;
            [_auron.physicsBody applyImpulse:ccp(0, 750.0f)];
        }
        
        // Plays audio effect
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"Jump.mp3"];
    }
}

// Resets jump identifiers
- (void)resetJump {
    jumped = false;
    doubleJump = false;
}

// Checks hits and removes hearts
- (void)removeHeart {
    if (hitCount == 1) {
        _heartTwo.visible = false;
    } else if (hitCount == 2) {
        _heartOne.visible = false;
    } else if (hitCount == 3) {
        _levelZero.paused = true;
        _levelZero.userInteractionEnabled = NO;
    }
}

// Checks collision and elimnates player if they touch the slime
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA slime:(CCNode *)nodeB {
    [_auron.physicsBody applyImpulse:ccp(0, 1000.f)];
    return true;
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA slime:(CCNode *)nodeB {
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"Jab.mp3"];
    hitCount = hitCount + 1;
    [self removeHeart];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA ground:(CCNode *)nodeB {
    [self resetJump];
    return true;
}

@end