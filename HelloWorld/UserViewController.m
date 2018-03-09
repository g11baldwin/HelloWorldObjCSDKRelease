//
//  UserViewController.m
//  HelloWorld
//
//  Created by JettBlack on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "UserViewController.h"

//Remember your import statements
#import "PPManager.h"

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;

@end

@implementation UserViewController


- (void)viewDidLoad {
	
    [super viewDidLoad];
    self.handleLabel.text = self.user.handle;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
	
	// The getProfilePic function returns a UIImage that you can use in a UIImageView.
    self.profileImageView.image =  [[PPManager sharedInstance].PPusersvc getProfilePic];
	
	// The getCoverPic function returns a UIImage that you can use in a UIImageView.
    self.coverPhotoImageView.image = [[PPManager sharedInstance].PPusersvc getCoverPic];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender {
	
	// Call the logout function to clear the current user's accessToken & refreshToken.
    [[PPManager sharedInstance].PPusersvc logout];
	
	[self dismissViewControllerAnimated:true completion:NULL];
	
}

@end
