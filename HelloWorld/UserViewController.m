//
//  UserViewController.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "UserViewController.h"
#import "PPManager.h"

@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end

@implementation UserViewController



- (void)viewDidLoad {
    [super viewDidLoad];
	self.topLabel.text = [NSString stringWithFormat:@"%@%@", @"Hello ", self.firstName];
    // Do any additional setup after loading the view.
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
