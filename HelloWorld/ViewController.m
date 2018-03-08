//
//  ViewController.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "ViewController.h"
#import "UserViewController.h"
#import "PPManager.h"
#import "PPLoginButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[PPManager sharedInstance].PPusersvc.addUserListener = ^(NSDictionary *user, NSError *error){
		if (error) {
			NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
		} else {
			for(id key in user) {
				NSLog(@"key=%@ value=%@", key, [user objectForKey:key]);
			}
			NSString *firstName = [user objectForKey:@"firstName"];
            NSString *lastName = [user objectForKey:@"lastName"];
			NSString *handle = [user objectForKey:@"handle"];
			NSString *userId = [user objectForKey:@"userId"];
			UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			UserViewController *vc = [sb instantiateViewControllerWithIdentifier:@"userViewController"];
			vc.firstName = firstName;
			vc.handle = handle;
			vc.userId = userId;
            vc.lastName = lastName;
			vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentViewController:vc animated:YES completion:NULL];
		}
	};
    
    
    //PPLoginButton handles all auth flow
    PPLoginButton *loginButton = [[PPLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
    //Or you can add a manual call to log a user in
    //[[PPManager sharedInstance].PPusersvc login];
    
}



@end
