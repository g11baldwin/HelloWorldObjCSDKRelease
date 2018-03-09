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
#import "PPUserObject.h"
#import "PPDataService.h"


@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;

@property (weak, nonatomic) IBOutlet UILabel *bucketCountLabel;
@end

@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.handleLabel.text = self.user.handle;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    self.profileImageView.image =  [[PPManager sharedInstance].PPusersvc getProfilePic];
    self.coverPhotoImageView.image = [[PPManager sharedInstance].PPusersvc getCoverPic];
    
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(d)
            self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", d?[[d valueForKey:@"inctest"] integerValue]:0];
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

- (IBAction)writeBucketTapped:(id)sender
{
    __block NSInteger last = 0;
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" handler:^(NSDictionary* d, NSError* error) {
        if(d) last = [[d valueForKey:@"inctest"] integerValue] + 1;
        self.bucketCountLabel.text = [NSString stringWithFormat:@"%ld", last];
        [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:(NSString*)@"inctest" andValue:[NSString stringWithFormat:@"%ld", last] push:FALSE handler:^(NSError *error) { }];
    }];
}
- (IBAction)emptyBucketTapped:(id)sender
{
    [[PPManager sharedInstance].PPdatasvc emptyBucket:[PPManager sharedInstance].PPuserobj.myDataStorage handler:^(NSError* error) { }];
    self.bucketCountLabel.text = [NSString stringWithFormat:@"%d", 0];
}
@end
