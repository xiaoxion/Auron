//
//  MainLevel.m
//  Auron
//
//  Created by Esau Rubio on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainLevel.h"
#import "VideoViewHelper.h"
#import "GameKitHelper.h"
#import <Parse/Parse.h>


@implementation MainLevel
LevelZero *mainLevel;

- (void)didLoadFromCCB {
    // Writes the Check for tutorial
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
    
    // Sets the delegate for the content nodes
    self.userInteractionEnabled = true;
    [LevelZero node];
    mainLevel = (LevelZero*) _levelZeroView.contentNode;
    mainLevel.delegate = self;
    _replayButton.visible = false;
}

// Scroll the level with the player
- (void)update:(CCTime)delta {
    if (!_levelZeroView.paused) {
        _levelZeroView.scrollPosition = ccp(_levelZeroView.scrollPosition.x + delta * 80.0f, _levelZeroView.scrollPosition.y);
    }
}

// Pause button interactions
- (void)onPause {
    if (_levelZeroView.paused) {
        _levelZeroView.paused = false;
        _levelZeroView.userInteractionEnabled = YES;
    } else {
        _levelZeroView.paused = true;
        _levelZeroView.userInteractionEnabled = NO;
    }
}

// If player reaches the end, they win to credits
-(void)onWin {
    GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];
    int64_t score = 0;
    if (_heartTwo.visible) {
        score = 2;
    } else if (_heartOne.visible) {
        score = 1;
    }
    
    VideoViewHelper *viewHelper = [VideoViewHelper sharedVideoViewHelper];
    viewHelper.videoName = @"CutScene";
    viewHelper.whichScene = @"CreditScene";
    viewHelper.score = [NSNumber numberWithLongLong:score];
    
    [viewHelper startVideoView];
    
    GKScore *daScore = [[GKScore alloc] init];
    daScore.value = score;
    
    [self retrieveAndUpdateWins];
    [gameKit submitScore:score category:@"gLeaderAuron"];
}

// Removes hearts if the player gets hit
- (void)removeHeart:(int)hitCount{
    if (hitCount == 1) {
        _heartTwo.visible = false;
    } else if (hitCount == 2) {
        // also shows replay button
        _heartOne.visible = false;
        _levelZeroView.paused = true;
        _levelZeroView.userInteractionEnabled = NO;
        _replayButton.visible = true;
        [self retrieveAndUpdateLoses];
    }
}

// removes tutorial
- (void)removeTutorial {
    _tutorial.visible = false;
}

// Sets the value to no and reinstatiates the level
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

-(void) retrieveAndUpdateWins {
    PFQuery *query = [PFQuery queryWithClassName:@"Wins"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            PFObject *temp = objects[0];
            int miniInt = [[temp objectForKey:@"score"] intValue] + 1;
            temp[@"score"] = [NSNumber numberWithInt:miniInt];
            [temp pinInBackground];
            
            if (miniInt > 0) {
                GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];
                if (miniInt > 4) {
                    if (![gameKit getAchievementByID:@"win_five"].completed) {
                        [gameKit reportAchievementWithID:@"win_five" percentComplete:100.0];
                    }
                    
                    return;
                }
                
                if (![gameKit getAchievementByID:@"win_one"].completed) {
                    [gameKit reportAchievementWithID:@"win_one" percentComplete:100.0];
                }
            }
        }
    }];
}

-(void) retrieveAndUpdateLoses {
    PFQuery *query = [PFQuery queryWithClassName:@"Loses"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            PFObject *temp = objects[0];
            int miniInt = [[temp objectForKey:@"score"] intValue] + 1;
            temp[@"score"] = [NSNumber numberWithInt:miniInt];
            [temp pinInBackground];
            
            if (miniInt > 1) {
                GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];
                [gameKit reportAchievementWithID:@"die_twice" percentComplete:100.0];
            }
        }
    }];
}

@end
