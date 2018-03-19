//
//  PPFriendsObject.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/9/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import "PPManager.h"
#import "PPUserObject.h"
#import "PPFriendsObject.h"

@implementation PPFriendsObject

- (void)inflateFriendsList:(NSMutableArray*) a
{
    _myFriends = a;
    NSLog(@"%@ myFriends array: %@", NSStringFromSelector(_cmd), _myFriends);
}
- (NSInteger)getFriendsCount
{
    return _myFriends.count;
}

- (UIImage*)getFriendsProfilePic:(NSString*)friendId
{
    for(PPUserObject* object in _myFriends) {
        if([object.userId isEqualToString:friendId]) {
            return([[PPManager sharedInstance].PPusersvc getProfilePic:object.profilePic]);
        }
    }
    return nil;
}
                   
@end
