//
//  LevelZero.h
//  Auron
//
//  Created by Esau Rubio on 11/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "MainScene.h"

@interface LevelZero : CCNode <CCPhysicsCollisionDelegate>
{
    CCNode* _auron;
    CCNode* _slime;
    CCNode* _ground;
    CCNode* _pauseButton;
    
    CCPhysicsNode* _physicsNode;
}

@end
