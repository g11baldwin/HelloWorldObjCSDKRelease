//
//  PPUserObject.m
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import "PPManager.h"
#import "PPUserObject.h"
#import "PDKeychainBindingsController.h"

@implementation PPUserObject

-(void)inflateWith:(NSDictionary*)d;
{
    NSLog(@"%@  dictionary:%@", NSStringFromSelector(_cmd), d);
    for(id key in d) {
        if([key isEqualToString:@"anonymous"]) {
            NSLog(@"not storing key:%@ value:%@", key, [d objectForKey:key]);
        } else {
            NSString* v = [d objectForKey:key];
            
            [[PPManager sharedInstance].PPuserobj setValue:v forKey:key];

//            if(v && ![key isEqualToString:@"parentFlags"] && ![key isEqualToString:@"profilePic"] && ![key isEqualToString:@"coverPhoto"]) {
//                NSLog(@"storing key:%@ value:%@", key, [d objectForKey:key]);
//                [[PDKeychainBindings sharedKeychainBindings] setObject:v forKey:key];  // save user profile in keychain
//            }
        }
    }

    NSLog(@"%@  PPuserobj:%@", NSStringFromSelector(_cmd), [PPManager sharedInstance].PPuserobj);

    // create stringname for this user's private data storage
    [PPManager sharedInstance].PPuserobj.myDataStorage = [self getMyDataStorageName];
    
    [PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage = [self getMyAppGlobalDataStorageName];

}

- (NSString*)getMyDataStorageName
{
    if(_handle) {
        return [NSString stringWithFormat:@"%@@%@", _handle, [[[NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]] componentsSeparatedByString:@"."] lastObject]];
    } else {
        return @"unknown";
    }
}
- (NSString*)getMyAppGlobalDataStorageName
{
        if(_handle) {
            return [NSString stringWithFormat:@"%@@%@", @"globalAppData", [[[NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]] componentsSeparatedByString:@"."] lastObject]];
        } else {
            return @"unknown";
        }
}

@end
