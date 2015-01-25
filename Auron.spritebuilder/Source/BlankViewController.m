//
//  BlankViewController.m
//  Auron
//
//  Created by Esau Rubio on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BlankViewController.h"
#import "GameKitHelper.h"
#import <Parse/Parse.h>

@interface BlankViewController ()

@end

@implementation BlankViewController
@synthesize whichScene,score;
NSArray *tempArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self retrieveScores];
    [self performSelector:@selector(enterNameAlert) withObject:nil afterDelay:.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TableView creation
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* const cellID = @"mainCell";
    UITableViewCell* aCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    PFObject *temp = tempArray[indexPath.row];
    NSString *tempString = [NSString stringWithFormat:@"%@                                        %@", temp[@"playerName"], temp[@"score"]];
    if( aCell == nil ) {
        aCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        aCell.textLabel.text = tempString;
    }
    return aCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tempArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *temp = tempArray[indexPath.row];
    [self share:[NSString stringWithFormat:@"Try to beat my highscore of %@ by %@ on Auron!", temp[@"score"], temp[@"playerName"]]];
}

#pragma Alerts
- (void)enterNameAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
                                }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        UITextField *name = alert.textFields.firstObject;
        GameKitHelper *gameKit = [GameKitHelper sharedGameKitHelper];
        [gameKit cachedScores:name.text score:score];
        [self retrieveScores];
                               }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 2;
    }
}

#pragma Information

-(IBAction)onDone:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:whichScene]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) retrieveScores {
    PFQuery *query = [PFQuery queryWithClassName:@"HighScore"];
    [query fromLocalDatastore];
    [query orderByDescending:@"sccore"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            tempArray = objects;
            [mainTableView reloadData];
        }
    }];
}

-(void)share:(NSString *)shared {
    NSArray *activityItems = @[shared];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
         NSLog(@"Activity = %@",activityType);
         NSLog(@"Completed Status = %d",completed);
         
         if (completed) {
             UIAlertView *objalert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Successfully Shared" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [objalert show];
             objalert = nil;
         }
     }];
}

@end
