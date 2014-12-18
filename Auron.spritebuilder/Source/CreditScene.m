//
//  CreditScene.m
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CreditScene.h"

@implementation CreditScene

// Plays the game and sends player to MainLevel Scene
- (void)onPlayButton {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

@end
