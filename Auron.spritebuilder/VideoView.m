//
//  VideoView.m
//  Auron
//
//  Created by Esau Rubio on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "VideoView.h"

@interface VideoView ()

@end

@implementation VideoView

@synthesize videoName, whichScene;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    
    MPMoviePlayerController *myPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    myPlayer.shouldAutoplay = YES;
    myPlayer.movieSourceType = MPMovieSourceTypeFile;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:myPlayer];
    [self setView:myPlayer.view];
    [myPlayer play];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    player.fullscreen = NO;
    
    if ([whichScene isEqualToString:@"IntroScene"]) {
        [CCBReader loadAsScene:@"MainScene"];
    } else if([whichScene isEqualToString:@"CutSceneOne"]) {
        [CCBReader loadAsScene:@"CreditScene"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
