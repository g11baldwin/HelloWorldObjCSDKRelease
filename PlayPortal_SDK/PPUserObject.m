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
        NSLog(@"key:%@ value:%@", key, [d objectForKey:key]);
        [[PPManager sharedInstance].PPuserobj setValue:[d objectForKey:key] forKey:key];
    }
    // create user's private data storage
    NSString* bundledappname = [NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]];
    NSArray* words = [bundledappname componentsSeparatedByString:@"."];
    NSString* appname = [words lastObject];
    
//    [PPManager sharedInstance].PPuserobj.myDataStorage = [NSString stringWithFormat:@"%@-%@", [[NSBundle mainBundle] bundleIdentifier], [PPManager sharedInstance].PPuserobj.handle];
        [PPManager sharedInstance].PPuserobj.myDataStorage = [NSString stringWithFormat:@"%@@%@", [PPManager sharedInstance].PPuserobj.handle, appname];
}

@end
