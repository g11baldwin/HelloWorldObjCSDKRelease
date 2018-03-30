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
    for(NSInteger i=0; i<[a count]; i++) {
        _myFriends = [NSMutableDictionary dictionaryWithObjects:a[i] forKeys:[a[i] valueForKey:@"userId"]];
        NSLog(@"_myFriends:%@", _myFriends);
    }
}
- (NSInteger)getFriendsCount
{
    return [_myFriends count];
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
- (NSDictionary*)getFriendAtIndex:(NSInteger)index
{
    if(index < [self getFriendsCount]) {
        NSArray* all = [_myFriends allKeys];
        return [[NSDictionary alloc] initWithDictionary:[_myFriends valueForKey:all[index]]];
    } else {
        return [[NSDictionary alloc] initWithObjectsAndKeys:@"unknown",@"Name: ", nil];
    }
}

@end
