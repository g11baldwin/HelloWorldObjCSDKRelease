//
//  FriendsTableViewController.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/28/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "FriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%@ friend count:%ld in section:%ld", NSStringFromSelector(_cmd), (long)[[PPManager sharedInstance].PPfriendsobj getFriendsCount], (long)section);
    return [[PPManager sharedInstance].PPfriendsobj getFriendsCount];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendcell" forIndexPath:indexPath];
    NSLog(@"indexpath=%@", indexPath);

    NSDictionary* d = [[PPManager sharedInstance].PPfriendsobj getFriendAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [d valueForKey:@"firstName"], [d valueForKey:@"lastName"]];

    return cell;
}

@end
