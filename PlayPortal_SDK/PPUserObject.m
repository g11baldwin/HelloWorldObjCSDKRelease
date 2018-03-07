//
//  PPUserObject.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import "PPManager.h"
#import "PPUserObject.h"

@implementation PPUserObject

-(void)inflateWith:(NSDictionary*)d;
{
    for(id key in d) {
        NSLog(@"key:%@", key);
        [[PPManager sharedInstance].PPuserobj setValue:[d objectForKey:key] forKey:key];
    }
}

@end
