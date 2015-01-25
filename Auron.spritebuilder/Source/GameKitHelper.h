//
//  GameKitHelper.h
//  Auron
//
//  Created by Esau Rubio on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import <GameKit/GameKit.h>

@protocol GameKitHelperProtocol

-(void) onLocalPlayerAuthenticationChanged;

-(void) onFriendListReceived:(NSArray*)friends;
-(void) onPlayerInfoReceived:(NSArray*)players;

-(void) onScoresSubmitted:(bool)success;
-(void) onScoresReceived:(NSArray*)scores;
-(void) onCachedScore: (GKScore *) score;

-(void) onAchievementReported:(GKAchievement*)achievement;
-(void) onAchievementsLoaded:(NSDictionary*)achievements;
-(void) onResetAchievements:(bool)success;

-(void) onLeaderboardViewDismissed;
-(void) onAchievementsViewDismissed;

@end

@interface GameKitHelper : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKLocalPlayerListener>
{
    id<GameKitHelperProtocol> __unsafe_unretained *  delegate;
    bool isGameCenterAvailable;
    NSError* lastError;
    
    
    NSMutableDictionary* achievements;
    NSMutableDictionary* cachedAchievements;
    NSMutableDictionary* cachedScores;
    
    UIViewController *tempVC;
}

@property (nonatomic, assign) id<GameKitHelperProtocol> delegate;
@property (nonatomic, readonly) bool isGameCenterAvailable;
@property (nonatomic, readonly) NSError* lastError;
@property (nonatomic, readonly) NSMutableDictionary* achievements;

/** returns the singleton object, like this: [GameKitHelper sharedGameKitHelper] */
+(GameKitHelper*) sharedGameKitHelper;

// Player authentication, info
-(void) authenticateLocalPlayer;
-(void) getLocalPlayerFriends;
-(void) getPlayerInfo:(NSArray*)players;

// Scores
-(void) cachedScores:(NSString *)name score:(NSNumber *)score;
-(void) submitScore:(int64_t)score category:(NSString*)category;
-(void) saveCachedScores;


// Achievements
-(GKAchievement*) getAchievementByID:(NSString*)identifier;
-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent;
-(void) resetAchievements;
-(void) reportCachedAchievements;
-(void) saveCachedAchievements;

// Game Center Views
-(void) showLeaderboard;
-(void) showAchievements;

@end