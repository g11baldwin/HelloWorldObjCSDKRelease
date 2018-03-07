//
//  UserViewController.h
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController

@property (readwrite, nonatomic, copy) NSString *firstName;
@property (readwrite, nonatomic, copy) NSString *handle;
@property (readwrite, nonatomic, copy) NSString *userId;

@end
