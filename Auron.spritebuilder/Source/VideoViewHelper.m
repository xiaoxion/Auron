//
//  VideoViewHelper.m
//  Auron
//
//  Created by Esau Rubio on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "VideoViewHelper.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VideoViewHelper
@synthesize videoName, whichScene;
MPMoviePlayerViewController *daPlayer;
static VideoViewHelper *instanceOfVideoViewHelper;

+(id) alloc {
    @synchronized(self)
    {
        instanceOfVideoViewHelper = [[super alloc] init];
        return instanceOfVideoViewHelper;
    }
    
    // to avoid compiler warning
    return nil;
}

+(VideoViewHelper*) sharedVideoViewHelper {
    @synchronized(self)
    {
        if (instanceOfVideoViewHelper == nil)
        {
            [[VideoViewHelper alloc] init];
        }
        
        return instanceOfVideoViewHelper;
    }
}

-(void)startVideoView {
    NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    daPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];

    daPlayer.moviePlayer.shouldAutoplay = YES;
    daPlayer.moviePlayer.fullscreen = YES;
    daPlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
    daPlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentMoviePlayerViewControllerAnimated:daPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:daPlayer.moviePlayer];
    [daPlayer.moviePlayer play];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    [self alertWithTableView];
}

-(UIViewController*) getRootViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

// TableView creation
+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* const SwitchCellID = @"SwitchCell";
    UITableViewCell* aCell = [tableView dequeueReusableCellWithIdentifier:SwitchCellID];
    if( aCell == nil ) {
        aCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        aCell.textLabel.text = [NSString stringWithFormat:@"Option"];
    }
    return aCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)alertWithTableView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Scores" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    UITableView *myView = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, 264, 150) style:UITableViewStyleGrouped];
    
    [myView setDelegate:self];
    [myView setDataSource:self];
    [alert addSubview:myView];
    [alert show];
}

- (void) alertViewCancel:(UIAlertView *)alertView {
    [daPlayer removeFromParentViewController];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:whichScene]];
}

@end
