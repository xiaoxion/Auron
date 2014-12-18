//
//  CreditScene.m
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CreditScene.h"

@implementation CreditScene
- (void)onClick {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}
@end
