//
//  ViewController.m
//  HelloWorld
//
//  Created by JettBlack on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
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
	
	//The callback function you provide will be called with a PPUserObject after a successful login
    [PPManager sharedInstance].PPusersvc.addUserListener = ^(PPUserObject *user, NSError *error){
		
		if (error) {
			
			NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
			
		} else {
			
            //We pass the PPUserObject to the UserViewController for display
			UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			UserViewController *vc = [sb instantiateViewControllerWithIdentifier:@"userViewController"];
            vc.user = user;
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
