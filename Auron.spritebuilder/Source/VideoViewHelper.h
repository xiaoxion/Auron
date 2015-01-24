//
//  VideoViewHelper.h
//  Auron
//
//  Created by Esau Rubio on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoViewHelper : NSObject <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    
}

@property NSString *videoName;
@property NSString *whichScene;

+(VideoViewHelper*) sharedVideoViewHelper;
-(void)startVideoView;

@end
