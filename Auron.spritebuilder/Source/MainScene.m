#import "MainScene.h"
#import "VideoViewHelper.h"
#import "GameKitHelper.h"

@implementation MainScene

- (void)didLoadFromCCB {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"FirstBoot.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"NO", nil] forKeys:[NSArray arrayWithObjects: @"FirstBoot", nil]];
        NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
        [plistData writeToFile:plistPath atomically:YES];
        
        VideoViewHelper *viewHelper = [VideoViewHelper sharedVideoViewHelper];
        viewHelper.videoName = @"IntroScene";
        viewHelper.whichScene = @"MainScene";

        [viewHelper startVideoView];
    }
}

// Checks if the user selects play and sents the tutorial pressed to NO
- (void)onPlay {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Tutorial.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"NO", nil] forKeys:[NSArray arrayWithObjects: @"TutorialPressed", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [plistData writeToFile:plistPath atomically:YES];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

// Checks if tutorial is pressed and sets the tutorial to YES
- (void)onTutorial {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Tutorial.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"YES", nil] forKeys:[NSArray arrayWithObjects: @"TutorialPressed", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [plistData writeToFile:plistPath atomically:YES];
    
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainLevel"]];
}

// Goes to credits
- (void)onCredits {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"CreditScene"]];
}

// Open Leaderboards
- (void)onLeaderboard {
    GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];
    
    [gameKit showLeaderboard];
}

@end
