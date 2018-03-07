//
//  PPUserService.h
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PPUserObject.h"

@interface PPUserService : NSObject
//@property (nonatomic, copy) void (^addUserListener)(NSDictionary* user, NSError *error);
@property (nonatomic, copy) void (^addUserListener)(PPUserObject* user, NSError *error);
- (void)login;
- (void)logout;
- (void)getProfile: (void(^)(NSError *error))handler;
- (UIImage*)getProfilePic;
- (NSString*)getMyId;
- (NSString*)getMyUsername;
@end
