//
//  LevelZero.h
//  Auron
//
//  Created by Esau Rubio on 11/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface LevelZero : CCNode <CCPhysicsCollisionDelegate>
{
    CCNode* _auron;
    CCNode* _slime;
    CCPhysicsNode* _physicsNode;
    NSDate* startTime;
}

@end
