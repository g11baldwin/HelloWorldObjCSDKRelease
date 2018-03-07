//
//  UserViewController.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "UserViewController.h"
#import "PPManager.h"


@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.handleLabel.text = self.handle;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    self.profileImageView.image = [[PPManager sharedInstance].PPusersvc getProfilePic];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    [[PPManager sharedInstance].PPusersvc logout];
	[self dismissViewControllerAnimated:true completion:NULL];
}

@end
