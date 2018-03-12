//
//  PPFriendsObject.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/9/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import "PPUserObject.h"
#import "PPFriendsObject.h"

@implementation PPFriendsObject

- (void)inflateFriendsList:(NSMutableArray*) a
{
    _myFriends = a;
    NSLog(@"%@ myFriends array: %@", NSStringFromSelector(_cmd), _myFriends);
}

@end
