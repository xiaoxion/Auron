//
//  GameKitHelper.m
//  Auron
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
// This copy was modified by Joshua Goossen to cache scores like what had already been done with the achievements.
// This copy was further modified by Esau Rubio to update some outdated methods and remove unneccesary code. 

#import "GameKitHelper.h"

static NSString* kCachedAchievementsFile = @"CachedAchievements.archive";
static NSString* kCachedScoresFile = @"CachedScores.archive";

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
-(void) initCachedScores;
-(void) cacheScore:(GKScore*) score forCategory: (NSString*)category;
-(void) uncacheScore:(GKScore*) score forCategory: (NSString*)category;
-(void) initCachedAchievements;
-(void) cacheAchievement:(GKAchievement*)achievement;
-(void) uncacheAchievement:(GKAchievement*)achievement;
-(void) loadAchievements;
-(UIViewController*) getRootViewController;
@end

@implementation GameKitHelper

static GameKitHelper *instanceOfGameKitHelper;

#pragma mark Singleton stuff
+(id) alloc
{
    @synchronized(self)
    {
        instanceOfGameKitHelper = [[super alloc] init];
        return instanceOfGameKitHelper;
    }
    
    // to avoid compiler warning
    return nil;
}

+(GameKitHelper*) sharedGameKitHelper
{
    @synchronized(self)
    {
        if (instanceOfGameKitHelper == nil) {
            [[GameKitHelper alloc] init];
        }
        return instanceOfGameKitHelper;
    }
    
    // to avoid compiler warning
    return nil;
}

#pragma mark Init & Dealloc

@synthesize isGameCenterAvailable;
@synthesize lastError;
@synthesize achievements;

-(id) init
{
    if ((self = [super init]))
    {
        // Test for Game Center availability
        Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
        bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
        
        // Test if device is running iOS 4.1 or higher
        NSString* reqSysVer = @"4.1";
        NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
        bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
        
        isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
        NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");
        
        [self registerForLocalPlayerAuthChange];
        
        [self initCachedAchievements];
        [self initCachedScores];
    }
    
    return self;
}

-(void) dealloc
{
    CCLOG(@"dealloc %@", self);
    
    instanceOfGameKitHelper = nil;
    
    [self saveCachedAchievements];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
    lastError = [error copy];
    
    if (lastError)
    {
        NSLog(@"GameKitHelper ERROR: %@", [[lastError userInfo] description]);
    }
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.authenticated == NO)
    {
        [localPlayer authenticateWithCompletionHandler:^(NSError* error)
         {
             [self setLastError:error];
             
             if (error == nil)
             {
                 [self reportCachedAchievements];
                 [self reportCachedScores];
                 [self loadAchievements];
             }
         }];
    }
}

-(void) onLocalPlayerAuthenticationChanged
{
    [_delegate onLocalPlayerAuthenticationChanged];
}

-(void) registerForLocalPlayerAuthChange
{
    if (isGameCenterAvailable == NO)
        return;
    
    // Register to receive notifications when local player authentication status changes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(onLocalPlayerAuthenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}

#pragma mark Friends & Player Info

-(void) getLocalPlayerFriends
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.authenticated)
    {
        // First, get the list of friends (player IDs)
        [localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
         {
             [self setLastError:error];
             [_delegate onFriendListReceived:friends];
         }];
    }
}

-(void) getPlayerInfo:(NSArray*)playerList
{
    if (isGameCenterAvailable == NO)
        return;
    
    // Get detailed information about a list of players
    if ([playerList count] > 0)
    {
        [GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
         {
             [self setLastError:error];
             [_delegate onPlayerInfoReceived:players];
         }];
    }
}

#pragma mark Scores & Leaderboard

-(void) initCachedScores
{
    NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedScoresFile];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    
    if ([object isKindOfClass:[NSMutableDictionary class]])
    {
        NSMutableDictionary* loadedScores = (NSMutableDictionary*)object;
        cachedScores = [[NSMutableDictionary alloc] initWithDictionary:loadedScores];
    }
    else
    {
        cachedScores = [[NSMutableDictionary alloc] init];
    }
}

-(void) cacheScore:(GKScore*) score forCategory: (NSString*)category
{
    GKScore *highScoreForCategory = [cachedScores objectForKey: category];
    NSLog(@"cacheScore: %lld forCategory: %@", score.value, category);
    //only cache the score if it is the highest score offline because gamecenter will only keep the highest anyway
    if (score.value > highScoreForCategory.value)
    {
        [cachedScores setObject:score forKey:category];
        // Save to disk immediately, to keep achievements around even if the game crashes.
        [self saveCachedScores];
    }
}

-(void) uncacheScore:(GKScore*) score forCategory: (NSString*)category
{
    NSLog(@"uncacheScore: %lld forCategory: %@", score.value, category);
    [cachedScores removeObjectForKey: category];
    
    // Save to disk immediately, to keep the removed cached scores from being loaded again
    [self saveCachedScores];
}

-(void) saveCachedScores
{
    NSLog(@"saveCachedScores");
    NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedScoresFile];
    [NSKeyedArchiver archiveRootObject:cachedScores toFile:file];
}

-(void) reportCachedScores
{
    NSLog(@"reportCachedScores");
    NSLog(@"isGameCenterAvailable: %i", isGameCenterAvailable);
    NSLog(@"[cachedScores count]: %lu", (unsigned long)[cachedScores count]);
    if (isGameCenterAvailable == NO)
        return;
    
    if ([cachedScores count] == 0)
        return;
    
    for (NSString *akey in cachedScores)
    {
        GKScore *score = [cachedScores objectForKey: akey];
        [score reportScoreWithCompletionHandler:^(NSError* error)
         {
             bool success = (error == nil);
             if (success == YES)
             {
                 NSLog(@"akey:%@", akey);
             }
             else
             {
                 NSLog(@"reportCachedSores failed");
             }
         }];
    }
    
}

-(void) submitScore:(int64_t)score category:(NSString*)category
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
    gkScore.value = score;
    
    [gkScore reportScoreWithCompletionHandler:^(NSError* error)
     {
         [self setLastError:error];
         
         bool success = (error == nil);
         if (success == NO)
         {
             // Keep score to try to submit it later
             [self cacheScore:gkScore forCategory: category];
         }
         [_delegate onScoresSubmitted:success];
     }];
}

#pragma mark Achievements

-(void) loadAchievements
{
    if (isGameCenterAvailable == NO)
        return;
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
     {
         [self setLastError:error];
         
         if (achievements == nil)
         {
             achievements = [[NSMutableDictionary alloc] init];
         }
         else
         {
             [achievements removeAllObjects];
         }
         
         for (GKAchievement* achievement in loadedAchievements)
         {
             [achievements setObject:achievement forKey:achievement.identifier];
         }
         
         [_delegate onAchievementsLoaded:achievements];
     }];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
    if (isGameCenterAvailable == NO)
        return nil;
    
    // Try to get an existing achievement with this identifier
    GKAchievement* achievement = [achievements objectForKey:identifier];
    
    if (achievement == nil)
    {
        // Create a new achievement object
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievements setObject:achievement forKey:achievement.identifier];
    }
    
    return achievement;
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKAchievement* achievement = [self getAchievementByID:identifier];
    if (achievement != nil && achievement.percentComplete < percent)
    {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError* error)
         {
             [self setLastError:error];
             
             bool success = (error == nil);
             if (success == NO)
             {
                 // Keep achievement to try to submit it later
                 [self cacheAchievement:achievement];
             }
             
             [_delegate onAchievementReported:achievement];
         }];
    }
}

-(void) resetAchievements
{
    if (isGameCenterAvailable == NO)
        return;
    
    [achievements removeAllObjects];
    [cachedAchievements removeAllObjects];
    
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
     {
         [self setLastError:error];
         bool success = (error == nil);
         [_delegate onResetAchievements:success];
     }];
}

-(void) reportCachedAchievements
{
    if (isGameCenterAvailable == NO)
        return;
    
    if ([cachedAchievements count] == 0)
        return;
    
    for (GKAchievement* achievement in [cachedAchievements allValues])
    {
        [achievement reportAchievementWithCompletionHandler:^(NSError* error)
         {
             bool success = (error == nil);
             if (success == YES)
             {
                 [self uncacheAchievement:achievement];
             }
         }];
    }
}

-(void) initCachedAchievements
{
    NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    
    if ([object isKindOfClass:[NSMutableDictionary class]])
    {
        NSMutableDictionary* loadedAchievements = (NSMutableDictionary*)object;
        cachedAchievements = [[NSMutableDictionary alloc] initWithDictionary:loadedAchievements];
    }
    else
    {
        cachedAchievements = [[NSMutableDictionary alloc] init];
    }
}

-(void) saveCachedAchievements
{
    NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
    [NSKeyedArchiver archiveRootObject:cachedAchievements toFile:file];
}

-(void) cacheAchievement:(GKAchievement*)achievement
{
    [cachedAchievements setObject:achievement forKey:achievement.identifier];
    
    // Save to disk immediately, to keep achievements around even if the game crashes.
    [self saveCachedAchievements];
}

-(void) uncacheAchievement:(GKAchievement*)achievement
{
    [cachedAchievements removeObjectForKey:achievement.identifier];
    
    // Save to disk immediately, to keep the removed cached achievement from being loaded again
    [self saveCachedAchievements];
}

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController*)vc
{
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES completion:nil];
}

-(void) dismissModalViewController
{
    UIViewController* rootVC = [self getRootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

// Leaderboards

-(void) showLeaderboard
{
    if (isGameCenterAvailable == NO)
        return;
    
    tempVC=[[UIViewController alloc] init] ;
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] !=NSOrderedAscending)
        
    {
        GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
        if (leaderboardVC != nil)
        {
            leaderboardVC.leaderboardDelegate = self;
            [self presentViewController:leaderboardVC];
        }
    }
    // added moet nog testen!!
    else
    {
        GKLeaderboardViewController *leaderboardVC = [[GKLeaderboardViewController alloc] init];
        
        if (leaderboardVC != nil)
        {
            
            leaderboardVC.leaderboardDelegate = self;
            [[[CCDirector sharedDirector] view] addSubview:tempVC.view];
            [tempVC  presentViewController:leaderboardVC animated:YES completion:nil];
            
        }
    }
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] !=NSOrderedAscending)
        
    {
        CCLOG(@"Done GC");
        [self dismissModalViewController];
    }
    else{
        [tempVC dismissViewControllerAnimated:YES completion:nil];
        [tempVC.view removeFromSuperview];
    }
    
}

// Achievements

-(void) showAchievements
{
    if (isGameCenterAvailable == NO)
        return;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    tempVC = [[UIViewController alloc] init];
    
    GKAchievementViewController* achievementsVC = [[GKAchievementViewController alloc] init];
    if (achievementsVC != nil)
    {
        achievementsVC.achievementDelegate = self;
        [[[CCDirector sharedDirector] view] addSubview:tempVC.view];
        [tempVC presentViewController:achievementsVC animated:YES completion:nil];
        achievementsVC.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(0.0f));
        [achievementsVC.view setCenter:CGPointMake(screenSize.height/2, screenSize.width/2)];
    }
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end