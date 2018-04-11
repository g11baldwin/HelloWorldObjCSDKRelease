
//
//  ViewController.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "ViewController.h"
#import "UserViewController.h"
#import <PlayPortal/PPManager.h>
#import <PlayPortal/PPLoginButton.h>

@interface ViewController ()
@property (readwrite, nonatomic, copy) NSString* myAge;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    [PPManager sharedInstance].PPusersvc.addUserListener = ^(PPUserObject *user, NSError *error){
		if (error) {
			NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
		} else {
            NSLog(@"username=%@", user.handle);
			UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			UserViewController *vc = [sb instantiateViewControllerWithIdentifier:@"userViewController"];
            vc.user = user;
			vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentViewController:vc animated:YES completion:NULL];

		}
	};

    //Or you can add a manual call to log a user in
    //[[PPManager sharedInstance].PPusersvc login];
    
    //PPLoginButton handles all auth flow
    PPLoginButton *loginButton = [[PPLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
}

- (IBAction)didTouchAnonymous
{
    int age = 12;
    [[PPManager sharedInstance].PPusersvc loginAnonymously:age];
}
@end
