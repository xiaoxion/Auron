//
//  BlankViewController.h
//  Auron
//
//  Created by Esau Rubio on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlankViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *mainTableView;
}

@property NSString *whichScene;
@property NSNumber *score;

-(IBAction)onDone:(id)sender;

@end
