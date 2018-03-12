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

- (void)inflateFriendsList:(NSDictionary*) d
{
    NSMutableArray* a;
    if(d) {
        NSLog(@"%@ friends dictionary: %@", NSStringFromSelector(_cmd), d);
        a = [d objectForKey:@"FriendsList"];
        if(a) {
            NSLog(@"%@ friends array: %@", NSStringFromSelector(_cmd), a);
        }
    }
}

@end
