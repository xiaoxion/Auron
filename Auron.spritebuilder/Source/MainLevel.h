//
//  MainLevel.h
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface MainLevel : CCNode
{
    CCScrollView* _levelZeroView;
    CCButton* _replayButton;
    CCNode* _heartOne;
    CCNode* _heartTwo;
    CCNode* _tutorial;
}

@end
