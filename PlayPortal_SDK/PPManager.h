//
//  PPManager.h
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#ifndef PPManager_h
#define PPManager_h

#import <Foundation/Foundation.h>
#import "PPUserService.h"
#import "PPDataService.h"
#import "AFNetworking.h"

@interface PPManager : NSObject
@property (readwrite, nonatomic, copy) NSString* apiUrlBase;
@property (readwrite, nonatomic, copy) NSString* accessToken;

@property PPUserObject *PPuserobj;
@property PPUserService *PPusersvc;
@property PPFriendsObject *PPfriendsobj;
@property PPDataService *PPdatasvc;

typedef NS_ENUM(NSInteger, PPManagerStatus) {
    PPStatusUnknown    = -1,
    PPStatusConfigured = 0,
    PPStatusOnline     = 1,
    PPStatusRefreshing = 2,
};

@property PPManagerStatus managerStatus;
@property (readwrite, nonatomic, copy) NSString* clientId;
@property (readwrite, nonatomic, copy) NSString* clientSecret;
@property (readwrite, nonatomic, copy) NSString* redirectURI;

+ (PPManager*)sharedInstance;
+ (AFHTTPSessionManager *)buildAF;
+ (NSMutableURLRequest *)buildAFRequestForBodyParms:(NSString*) verb andUrlString:(NSString*)urlString;
+ (void)processAFError:(NSError*) e;
+ (void)processAFResponse:(NSDictionary*) d;
- (void)configure:(NSString *)clientId secret:(NSString*)secret andRedirectURI:(NSString*)redirectURI;
- (void)getProfileAndBucket:(void(^)(NSError *error))handler;
- (void)handleOpenURL:(NSURL *)url;
- (void)getInitialToken:(void(^)(NSError *error))handler;
- (void)refreshAccessToken:(void(^)(NSError *error))handler;
- (NSString*)getAccessToken;
- (BOOL)isAuthenticated;
-(void)logout;

@end
#endif
