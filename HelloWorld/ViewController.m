
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

-(void) viewDidAppear:(BOOL)animated
{
    NSString* myAge = [[PPManager sharedInstance] getAge];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSLog(@"myAge: %@", [f numberFromString:myAge]);
    if([f numberFromString:myAge] > 0) {
        NSLog(@"myAge: %@", [f numberFromString:myAge]);
        return;
    } else {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Enter your age"
                                                                                  message: @"Enter your age"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"12";
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields =alertController.textFields;
            UITextField * agefield = textfields[0];
            _myAge = agefield.text;
            NSLog(@"\nMy age is: %@\n", _myAge);
            [[PPManager sharedInstance] captureAge: _myAge];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)didTouchAnonymous
{
    [PPManager sharedInstance].PPusersvc.addUserListener = ^(PPUserObject *user, NSError *error){
    if (error) {
        [[PPManager sharedInstance] isAuthenticated:^(BOOL isAuthenticated, NSError* error) {
            if(isAuthenticated != TRUE) {
                [[PPManager sharedInstance].PPusersvc loginAnonymously:[[NSDate alloc] initWithTimeIntervalSinceNow:0]]; // use "now" as birthdate
            }
        }];
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
    [[PPManager sharedInstance] isAuthenticated:^(BOOL isAuthenticated, NSError* error) {
        if (!isAuthenticated) {
            [[PPManager sharedInstance].PPusersvc loginAnonymously:[[NSDate alloc] initWithTimeIntervalSinceNow:0]];
        } else {
            PPUserObject *user = [PPManager sharedInstance].PPuserobj;
            NSLog(@"username=%@", [PPManager sharedInstance].PPuserobj.handle);
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UserViewController *vc = [sb instantiateViewControllerWithIdentifier:@"userViewController"];
            vc.user = user;
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:vc animated:YES completion:NULL];
        }
    }];
}
@end
