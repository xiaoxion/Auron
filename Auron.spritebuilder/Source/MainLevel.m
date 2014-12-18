//
//  MainLevel.m
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainLevel.h"

@implementation MainLevel
LevelZero *mainLevel;

- (void)didLoadFromCCB {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"Tutorial.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Tutorial" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    
    if ([[temp objectForKey:@"TutorialPressed"] isEqualToString:@"NO"]) {
        _tutorial.visible = false;
    }
    
    self.userInteractionEnabled = true;
    [LevelZero node];
    mainLevel = _levelZeroView.contentNode;
    mainLevel.delegate = self;
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

-(void)onWin {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"CreditScene"]];
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

- (void)removeTutorial {
    _tutorial.visible = false;
}

- (void)onReplay {
    mainLevel.delegate = nil;
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Tutorial.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"NO", nil] forKeys:[NSArray arrayWithObjects: @"TutorialPressed", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [plistData writeToFile:plistPath atomically:YES];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

@end
