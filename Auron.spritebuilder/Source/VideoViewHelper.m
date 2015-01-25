//
//  VideoViewHelper.m
//  Auron
//
//  Created by Esau Rubio on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "VideoViewHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BlankViewController.h"

@implementation VideoViewHelper
@synthesize videoName, whichScene, score;
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
    BlankViewController *blank = [[BlankViewController alloc] init];
    UIViewController* rootVC = [self getRootViewController];
    blank.score = score;

    blank.whichScene = whichScene;
    [rootVC presentViewController:blank animated:YES completion:nil];
}

-(UIViewController*) getRootViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
