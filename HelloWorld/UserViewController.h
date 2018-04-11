//
//  UserViewController.h
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PlayPortal/PPUserObject.h>

@interface UserViewController : UIViewController

@property (readwrite, nonatomic) PPUserObject *user;
@end
