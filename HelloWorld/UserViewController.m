//
//  UserViewController.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "UserViewController.h"
#import "FriendsTableViewController.h"
#import "PPManager.h"
#import "PPUserObject.h"
#import "PPDataService.h"


@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;

@property (weak, nonatomic) IBOutlet UILabel *bucketCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalBucketCountLabel;
@end

@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.handleLabel.text = self.user.handle;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName?self.user.firstName:@"anonymous", self.user.lastName?self.user.lastName:@"user"];
    if(self.user.firstName) {
        self.profileImageView.image =  [[PPManager sharedInstance].PPusersvc getProfilePic:self.user.userId];
        self.coverPhotoImageView.image = [[PPManager sharedInstance].PPusersvc getCoverPic:self.user.userId];
    } else {
        self.profileImageView.image= [UIImage imageNamed:@"unknown_user.jpg"];
        self.coverPhotoImageView.image = [UIImage imageNamed:@"unknown_user.jpg"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{ [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(d) {
            self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", d?[[d valueForKey:@"inctest"] integerValue]:0];
        }
    }]; } );
    dispatch_async(dispatch_get_main_queue(), ^{ [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(d) {
            self.globalBucketCountLabel.text = [NSString stringWithFormat:@"%ld", d?[[d valueForKey:@"inctest"] integerValue]:0];
        }
    }]; } );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    [[PPManager sharedInstance].PPusersvc logout];
	[self dismissViewControllerAnimated:true completion:NULL];
}

- (IBAction)writeBucketTapped:(id)sender
{
    __block NSInteger last = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(d) last = [[d valueForKey:@"inctest"] integerValue] + 1;

        [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" andValue:[NSString stringWithFormat:@"%ld", last] push:FALSE handler:^(NSError *error) {
            self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", last];
        }];
    }];
    });
}
- (IBAction)emptyBucketTapped:(id)sender
{
    [[PPManager sharedInstance].PPdatasvc emptyBucket:[PPManager sharedInstance].PPuserobj.myDataStorage handler:^(NSError* error) { }];
    self.bucketCountLabel.text = [NSString stringWithFormat:@"%d", 0];
}


- (IBAction)writeGlobalBucketTapped:(id)sender
{
    __block NSInteger last = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
            if(d) last = [[d valueForKey:@"inctest"] integerValue] + 1;
            
            [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" andValue:[NSString stringWithFormat:@"%ld", last] push:FALSE handler:^(NSError *error) {
                self.globalBucketCountLabel.text = [NSString stringWithFormat:@"%ld", last];
            }];
        }];
    });
}

- (IBAction)getFriendsTapped:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PPManager sharedInstance].PPusersvc getFriendsProfiles:^(NSError *error) {
            NSLog(@"%@ getFriendsTapped: %@", NSStringFromSelector(_cmd), @" fetching friends list from server or cache");
            [self performSegueWithIdentifier:@"friendcontainersegue" sender:self];
            
            if (error) {
                NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
            }
        }];
    });
}

@end
