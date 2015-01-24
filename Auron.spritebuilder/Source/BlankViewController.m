//
//  BlankViewController.m
//  Auron
//
//  Created by Esau Rubio on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BlankViewController.h"

@interface BlankViewController ()

@end

@implementation BlankViewController
@synthesize whichScene;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TableView creation
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int juan = 1;
}

- (void)alertWithTableView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Scores" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)onExit {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:whichScene]];
    [self removeFromParentViewController];
}

@end
