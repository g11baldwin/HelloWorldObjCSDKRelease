//
//  PPFriendsObject.h
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/9/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PPUserObject.h"

@interface PPFriendsObject : PPUserObject
@property NSMutableArray *myFriends;

- (void)inflateFriendsList:(NSMutableArray*)a;

@end
