//
//  LevelZero.m
//  Auron
//
//  Created by Esau Rubio on 11/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelZero.h"
#import <Parse/Parse.h>
#import "GameKitHelper.h"

static const CGFloat speed = 80.0f;

@implementation LevelZero
@synthesize delegate;

NSDate* startJump;
NSDate* startSound;
int hitCount = 0;
bool jumped = false;
bool doubleJump = false;
bool onWinOnce = false;

// Initialization and Loading of assets.
- (void)didLoadFromCCB {
    hitCount = 0;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _slimeOne.physicsBody.collisionType = @"slime";
    _slimeTwo.physicsBody.collisionType = @"slime";
    _auron.physicsBody.collisionType = @"hero";
    _ground.physicsBody.collisionType = @"ground";
    _gemOne.physicsBody.collisionType = @"gem";
    _gemTwo.physicsBody.collisionType = @"gem";
    _gemThree.physicsBody.collisionType = @"gem";
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"Jump.mp3"];
    [audio preloadEffect:@"Jab.mp3"];
}

// Moves player and Slime
- (void)update:(CCTime)delta {
    if (_auron.position.x < 1130.0f) {
        _auron.position = ccp(_auron.position.x + delta * speed, _auron.position.y);
    } else {
        if (!onWinOnce) {
            onWinOnce = true;
            [delegate onWin];
        }
    }
    _slimeOne.position = ccp(_slimeOne.position.x - delta * speed, _slimeOne.position.y);
    _slimeTwo.position = ccp(_slimeTwo.position.x - delta * speed, _slimeTwo.position.y);
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
        
        [delegate removeTutorial];
        
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

// Checks collision and elimnates player if they touch the slime
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA slime:(CCNode *)nodeB {
    [_auron.physicsBody applyImpulse:ccp(0, 500.f)];
    return true;
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA slime:(CCNode *)nodeB {
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"Jab.mp3"];
    hitCount = hitCount + 1;
    // Sends the delegate to remove the heart
    [delegate removeHeart:hitCount];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA ground:(CCNode *)nodeB {
    [self resetJump];
    return true;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA gem:(CCNode *)nodeB {
    if ([nodeB.name isEqualToString:@"gOne"]) nodeB.visible = false;
    if ([nodeB.name isEqualToString:@"gTwo"]) nodeB.visible = false;
    if ([nodeB.name isEqualToString:@"gThree"]) nodeB.visible = false;
    
    [self retrieveAndUpdateGems];
    
    return true;
}

-(void) retrieveAndUpdateGems {
    PFQuery *query = [PFQuery queryWithClassName:@"Gems"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            PFObject *temp = objects[0];
            int miniInt = [[temp objectForKey:@"score"] intValue] + 1;
            temp[@"score"] = [NSNumber numberWithInt:miniInt];
            [temp pinInBackground];
            
            GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];

            if (miniInt > 49) {
                if (![gameKit getAchievementByID:@"fifty_gems"].completed) {
                    [gameKit reportAchievementWithID:@"fifty_gems" percentComplete:100.0];
                }
                return;
            }
            
            if (miniInt > 24) {
                if (![gameKit getAchievementByID:@"twentyfive_gems"].completed) {
                    [gameKit reportAchievementWithID:@"twentyfive_gems" percentComplete:100.0];
                }
                return;
            }
            
            if (miniInt > 9) {
                if (![gameKit getAchievementByID:@"ten_gems"].completed) {
                    [gameKit reportAchievementWithID:@"ten_gems" percentComplete:100.0];
                }
            }
        }
    }];
}

@end