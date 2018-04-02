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
        }
    }
    NSLog(@"%@  PPuserobj:%@", NSStringFromSelector(_cmd), [PPManager sharedInstance].PPuserobj);

    // gen names for this user's private/global data storage
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
            return [NSString stringWithFormat:@"%@%@@%@", @"globalAppData", ([PPManager sharedInstance].getAgeInt < 13)?@"-u13":@"", [[[NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]] componentsSeparatedByString:@"."] lastObject]];
        } else {
            return @"unknown";
        }
}

@end
