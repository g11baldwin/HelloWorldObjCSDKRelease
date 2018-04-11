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
#import <PlayPortal/PPManager.h>
#import <PlayPortal/PPUserObject.h>
#import <PlayPortal/PPDataService.h>


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
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    self.profileImageView.image =  [[PPManager sharedInstance].PPusersvc getProfilePic:self.user.userId];
    self.coverPhotoImageView.image = [[PPManager sharedInstance].PPusersvc getCoverPic:self.user.userId];

    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(error) {
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
        } else if (d) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", d ? (long)[[d valueForKey:@"inctest"] integerValue] : (long)0];
            } );
        }
    }];
    
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(error) {
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
        } else if (d) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.globalBucketCountLabel.text = [NSString stringWithFormat:@"%ld", d ? (long)[[d valueForKey:@"inctest"] integerValue] : (long)0];
            });
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender {
    [[PPManager sharedInstance].PPusersvc logout];
	[self dismissViewControllerAnimated:true completion:NULL];
}

- (IBAction)writeBucketTapped:(id)sender
{
    __block NSInteger last = 0;
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if (error) {
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
        } else if (d) {
            last = [[d valueForKey:@"inctest"] integerValue] + 1;
            [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" andValue:[NSString stringWithFormat:@"%ld", (long)last] push:FALSE handler:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", (long)last];
                });
            }];
        }
    }];
}

- (IBAction)emptyBucketTapped:(id)sender
{
    [[PPManager sharedInstance].PPdatasvc emptyBucket:[PPManager sharedInstance].PPuserobj.myDataStorage handler:^(NSError* error) { }];
    self.bucketCountLabel.text = [NSString stringWithFormat:@"%d", 0];
}

- (IBAction)writeGlobalBucketTapped:(id)sender
{
    __block NSInteger last = 0;
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        
        if (error) {
            
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
            
        } else if (d) {
            
            last = [[d valueForKey:@"inctest"] integerValue] + 1;
            [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andKey:(NSString*)@"inctest" andValue:[NSString stringWithFormat:@"%ld", (long)last] push:FALSE handler:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.globalBucketCountLabel.text = [NSString stringWithFormat:@"%ld", (long)last];
                });
            }];
            
        }
        
    }];
};

- (IBAction)getFriendsTapped:(id)sender {
    [[PPManager sharedInstance].PPusersvc getFriendsProfiles:^(NSError *error) {
        if (error) {
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
        } else {
            [self performSegueWithIdentifier:@"friendcontainersegue" sender:self];
        }
    }];
};

@end
