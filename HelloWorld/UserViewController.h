//
//  UserViewController.h
//  HelloWorld
//
//  Created by JettBlack on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPUserObject.h"

@interface UserViewController : UIViewController

@property (readwrite, nonatomic) PPUserObject *user;

@end
