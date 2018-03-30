//
//  FriendContainerViewController.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/28/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "FriendContainerViewController.h"

@interface FriendContainerViewController ()

@end

@implementation FriendContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButton:(id)sender
{
    NSLog(@"back button");
    [self dismissViewControllerAnimated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
