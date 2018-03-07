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
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end

@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.topLabel.text = [NSString stringWithFormat:@"%@%@", @"Hello ", self.firstName];
    
    [[PPManager sharedInstance].PPusersvc getProfilePic:^(UIImage *userProfilePic, NSError *error) {
        if(!error) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:userProfilePic];
            imageView.frame = CGRectMake(160,300, 120,120);
            imageView.opaque = FALSE;
            [self.view addSubview:imageView];
        } 
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    [[PPManager sharedInstance].PPusersvc logout];
	[self dismissViewControllerAnimated:true completion:NULL];
}

- (IBAction)getProfile:(id)sender {
    [[PPManager sharedInstance].PPusersvc getProfile:^(NSError* error) {
        if(!error) {
            NSLog(@"handle=%@", self.handle);
        }
    }];
}



@end
