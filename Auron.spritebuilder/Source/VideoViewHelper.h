//
//  VideoViewHelper.h
//  Auron
//
//  Created by Esau Rubio on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoViewHelper : NSObject
{
    
}

@property NSString *videoName;
@property NSString *whichScene;
@property NSNumber *score;

+(VideoViewHelper*) sharedVideoViewHelper;
-(void)startVideoView;

@end
