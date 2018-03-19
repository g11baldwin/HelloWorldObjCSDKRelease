//
//  PPManager.m
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#import "PPManager.h"
#import "AFNetworking.h"
#import "AFImageDownloader.h"
#import "PDKeychainBindingsController.h"


@interface PPManager()

@property (readwrite, nonatomic, copy) NSString* oauthURL;
@property (readwrite, nonatomic, copy) NSString* refreshToken;
@property (readwrite, nonatomic, copy) NSString* tokenType;
@property (readwrite, nonatomic, copy) NSString* apiOauthBase;
@property (readwrite, nonatomic, copy) NSString* authCode;
@property (readwrite, nonatomic, copy) NSDate* expirationTime;

@property (readwrite, nonatomic) BOOL loading;

@end

@implementation PPManager

+ (PPManager*)sharedInstance
{
    static PPManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PPManager alloc] init];
        _sharedInstance.apiUrlBase = [NSMutableString stringWithString:@"https://sandbox.iokids.net"];
        _sharedInstance.apiOauthBase = [NSMutableString stringWithString:@"https://sandbox.iokids.net/oauth"];
        _sharedInstance.PPusersvc = [[PPUserService alloc] init];
        _sharedInstance.PPdatasvc = [[PPDataService alloc] init];
        _sharedInstance.PPuserobj = [[PPUserObject alloc] init];
        _sharedInstance.PPfriendsobj = [[PPFriendsObject alloc] init];
    });
    return _sharedInstance;
}

+ (AFHTTPSessionManager *)buildAF
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *btoken = [NSString stringWithFormat:@"%@ %@", @"Bearer", [PPManager sharedInstance].accessToken];
    [manager.requestSerializer setValue:btoken forHTTPHeaderField:@"Authorization"];
    return manager;
}

+ (NSMutableURLRequest *)buildAFRequestForBodyParms:verb andUrlString:(NSString*)urlString
{
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: verb URLString:[NSString stringWithString:urlString] parameters:nil error:nil];
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    NSString *btoken = [NSString stringWithFormat:@"%@ %@", @"Bearer", [PPManager sharedInstance].accessToken];
    [req setValue:btoken forHTTPHeaderField:@"Authorization"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return(req);
}

+ (void)processAFError:(NSError*) e
{
    [[PPManager sharedInstance] refreshAccessToken:^(NSError *error){}];
}
+ (void)processAFResponse:(NSDictionary*) d
{
    if((d &&
        (([d objectForKey:@"error_code"] == 0x4011) && [[d objectForKey:@"error_description"] isEqualToString:@"Application does not have permission"])) ||
        (([d objectForKey:@"error_code"] == 0x401) && [[d objectForKey:@"error_description"] isEqualToString:@"Bad access token!"])) {
        [[PPManager sharedInstance] refreshAccessToken:^(NSError *error){}];
    }
}

- (NSString*)getAccessToken
{
    return _accessToken;
}
- (void)configure:(NSString *)clientId secret:(NSString*)secret andRedirectURI:(NSString*)redirectURI
{
    if(!clientId || !secret || !redirectURI) {
        NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), @"Please provide a clientId, clientSecret & redirectURI.");
    } else {
        [PPManager sharedInstance].clientId = clientId;
        [PPManager sharedInstance].clientSecret = secret;
        [PPManager sharedInstance].redirectURI = redirectURI;
        [PPManager sharedInstance].managerStatus = PPStatusConfigured;
        [[PPManager sharedInstance] isAuthenticated:^(BOOL isAuthenticated, NSError* error) {
            if (isAuthenticated) {
                [[PPManager sharedInstance] getProfileAndBucket:^(NSError* error) {
                    if (error) {
                        [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
                    } else {
                        [PPManager sharedInstance].PPusersvc.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
                    }
                }];
            } else if (error) {
                [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
            } else {
                if ([PPManager sharedInstance].PPusersvc.addUserListener != NULL) {
                    [PPManager sharedInstance].PPusersvc.addUserListener(NULL, NULL);
                }
            }
        }];
    }
}
- (void)getProfileAndBucket:(void(^)(NSError *error))handler
{
    [[PPManager sharedInstance].PPusersvc getProfile:^(NSError *error){
        if (error) {
            NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
            handler(error);
        } else {
            // attempt to create / open this user's private data storage
            NSLog(@"%@ userObj:%@", NSStringFromSelector(_cmd), [PPManager sharedInstance].PPuserobj.userId);
            [[PPManager sharedInstance].PPdatasvc openBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andUsers:(NSArray *)[NSArray arrayWithObjects:[PPManager sharedInstance].PPuserobj.userId, nil] handler:^(NSError* error) {
                if(error) {
                    NSLog(@"%@ Error: Unable to open/create user bucket - %@", NSStringFromSelector(_cmd), error);
                    handler(error);
                } else {
                    handler(NULL);
                }
            }];
        }
    }];
}
     
// After SSO, redirect sends app here to begin
- (void)handleOpenURL:(NSURL *)url
{
    NSArray *strs = [url.absoluteString componentsSeparatedByString:@"="];
    if(strs.count >= 3) {
        NSArray *substrs = [strs[1] componentsSeparatedByString:@"&"];
        [PPManager sharedInstance].authCode = substrs[0];
        [[PDKeychainBindings sharedKeychainBindings] setObject:_authCode forKey:@"auth_code"];  // save auth_code in keychain

        [[PPManager sharedInstance] getInitialToken:^(NSError *error){
            if (error) {
                NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
                [self dismissTopVC];
            } else {
                [[PPManager sharedInstance] getProfileAndBucket:^(NSError* error) {
                    if (!error) {
                        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
                        while (topController.presentedViewController) {
                            topController = topController.presentedViewController;
                        }
                        [topController dismissViewControllerAnimated:true completion:^(void){
                            [PPManager sharedInstance].PPusersvc.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
                        }];
                    } else {
                        [self dismissTopVC];
                    }
                }];
            }
        }];
    }
}

-(void)dismissTopVC {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController dismissViewControllerAnimated:true completion:NULL];
}

// After SSO auth, get an access token for validating API requests
- (void)getInitialToken:(void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiOauthBase, @"token"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [PPManager sharedInstance].redirectURI,@"redirect_uri",
                           [PPManager sharedInstance].clientId,@"client_id",
                           [PPManager sharedInstance].clientSecret,@"client_secret",
                           @"authorization_code",@"grant_type",
                           [PPManager sharedInstance].authCode,@"code",
                           nil ];
    NSLog(@"parms: %@", parms);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url.absoluteString parameters:parms progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"%@  responseObject: %@", NSStringFromSelector(_cmd), responseObject);
        [PPManager sharedInstance].refreshToken = [responseObject objectForKey:@"refresh_token"];
        [PPManager sharedInstance].accessToken = [responseObject objectForKey:@"access_token"];
        [PPManager sharedInstance].tokenType = [responseObject objectForKey:@"token_type"];
        [PPManager sharedInstance].expirationTime = [[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"] ? [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 12)] : [[NSDate alloc] initWithTimeIntervalSinceNow:(1)];  // cause token to renew @ 1/2 expiration period
        [PPManager sharedInstance].managerStatus = PPStatusOnline;
        [self storeTokensInKeychain];
        handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        handler(error);
    }];
}

- (void)refreshAccessToken:(void(^)(NSError *error))handler
{
    NSLog(@"%@  refreshAccessToken", NSStringFromSelector(_cmd));
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiOauthBase, @"token"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @"refresh_token",@"grant_type",
                           [PPManager sharedInstance].refreshToken,@"refresh_token",
                           [PPManager sharedInstance].clientId,@"client_id",
                           [PPManager sharedInstance].clientSecret,@"client_secret",
                           nil ];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url.absoluteString parameters:parms progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"%@  responseObject: %@", NSStringFromSelector(_cmd), responseObject);
        [PPManager sharedInstance].refreshToken = [responseObject objectForKey:@"refresh_token"];
        [PPManager sharedInstance].accessToken = [responseObject objectForKey:@"access_token"];
        [PPManager sharedInstance].tokenType = [responseObject objectForKey:@"token_type"];
        NSInteger delta = 10000000;
        if([[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"]) {
            delta = 3600 * 11;
        }

        [PPManager sharedInstance].expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:delta];
        [self storeTokensInKeychain];
        handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        handler(error);
    }];
}

- (void)storeTokensInKeychain {
    [[PDKeychainBindings sharedKeychainBindings] setObject:_refreshToken forKey:@"refresh_token"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:_accessToken forKey:@"access_token"];
    NSDateFormatter* rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringDate = [rfc3339DateFormatter stringFromDate:[PPManager sharedInstance].expirationTime];
    [[PDKeychainBindings sharedKeychainBindings] setObject:stringDate forKey:@"expiration_time"];
}


- (void)isAuthenticated:(void(^)(BOOL isAuthenticated, NSError*  error))handler
{
    NSString* rt = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"refresh_token"];
    NSString* at = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"access_token"];
    NSString* et = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"];
    NSString* ac = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"auth_code"];
    NSLog(@"%@ keychain parms: rt:%@  at:%@  et:%@  ac:%@", NSStringFromSelector(_cmd), rt, at, et, ac);
    if([self allTokensExist]) {
        if ([[PPManager sharedInstance] tokensNotExpired]) {
            [PPManager sharedInstance].refreshToken = rt;
            [PPManager sharedInstance].accessToken = at;
            handler(TRUE, NULL);
        } else {
            [[PPManager sharedInstance] refreshAccessToken:^(NSError *error){
                if (error) {
                    NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
                    [[PPManager sharedInstance] logout];
                    handler(FALSE, error);
                } else {
                    handler(TRUE, NULL);
                }
            }];
        }
    } else {
        [[PPManager sharedInstance] logout];
        handler(FALSE, NULL);
    }
}

-(BOOL)allTokensExist {
    NSString* rt = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"refresh_token"];
    NSString* et = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"];
    return !(!rt || !et);
}

-(BOOL)tokensNotExpired {
    NSString* et = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"];
    NSDateFormatter* rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSDate* dateFromString;
    [rfc3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFromString = [rfc3339DateFormatter dateFromString:et];
    _expirationTime = dateFromString;
    if([[NSDate date] compare: dateFromString] == NSOrderedAscending) {
        return TRUE;
    } else {
        return FALSE;
    };
}
         
-(void)logout {
    [PPManager sharedInstance].refreshToken = NULL;
    [PPManager sharedInstance].accessToken = NULL;
    // invalidate token info in keychain by setting expiration time==now()
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringDate = [rfc3339DateFormatter stringFromDate:[NSDate date]];
//    [[PDKeychainBindings sharedKeychainBindings] setObject:stringDate forKey:@"expiration_time"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"auth_code"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"access_token"];
    
}


- (void)initKeychain
{
    
}


@end


