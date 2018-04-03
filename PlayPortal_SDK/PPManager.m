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


#ifdef TEST_SERVER
        _sharedInstance.apiUrlBase = [NSMutableString stringWithString:@"https://iokids-test-api.mybluemix.net"];
       _sharedInstance.apiOauthBase = [NSMutableString stringWithString:@"https://iokids-test-api.mybluemix.net/oauth"];
#else
        _sharedInstance.apiUrlBase = [NSMutableString stringWithString:@"https://sandbox.iokids.net"];
        _sharedInstance.apiOauthBase = [NSMutableString stringWithString:@"https://sandbox.iokids.net/oauth"];
#endif
        _sharedInstance.PPusersvc = [[PPUserService alloc] init];
        _sharedInstance.PPdatasvc = [[PPDataService alloc] init];
        _sharedInstance.PPuserobj = [[PPUserObject alloc] init];
       
        _sharedInstance.PPuserobj.handle = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"handle"]; // restore key parts of user profile from keychain
        _sharedInstance.PPuserobj.userId = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"userId"];
        _sharedInstance.PPuserobj.userType = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"userType"];
        _sharedInstance.PPuserobj.myDataStorage = [_sharedInstance.PPuserobj getMyDataStorageName];
        NSLog(@"%@ handle (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.PPuserobj.handle);
        NSLog(@"%@ userId (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.PPuserobj.userId);
        NSLog(@"%@ userType (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.PPuserobj.userType);
        NSLog(@"%@ myDataStorage (synth from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.PPuserobj.myDataStorage);
        
        _sharedInstance.PPfriendsobj = [[PPFriendsObject alloc] init];
        
        _sharedInstance.refreshToken = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"refresh_token"];
        _sharedInstance.accessToken = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"access_token"];
        _sharedInstance.expirationTime = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"];
        _sharedInstance.authCode = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"auth_code"];
        
        NSLog(@"%@ refresh_token (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.refreshToken);
        NSLog(@"%@ access_token (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.accessToken);
        NSLog(@"%@ expiration_time (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.expirationTime);
        NSLog(@"%@ auth_code (from keychain): %@", NSStringFromSelector(_cmd), _sharedInstance.authCode);
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

+ (void)processAFError:(NSError*)e  withRetryBlock:(void (^)(void))retryBlock
{
    NSLog(@"%@ error: %@\n", NSStringFromSelector(_cmd), e);
    [[PPManager sharedInstance] refreshAccessToken:^(NSError *error){
        if(!error && retryBlock) retryBlock();
    }];
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
            [[PPManager sharedInstance].PPdatasvc openBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andUsers:(NSArray *)[NSArray arrayWithObjects:[PPManager sharedInstance].PPuserobj.userId, nil] public:@"FALSE" handler:^(NSError* error) {
                [[PPManager sharedInstance].PPusersvc getFriendsProfiles:^(NSError *error2) {

                    [[PPManager sharedInstance].PPdatasvc openBucket:[PPManager sharedInstance].PPuserobj.myAppGlobalDataStorage andUsers:(NSArray *)[NSArray arrayWithObjects:[PPManager sharedInstance].PPuserobj.userId, nil] public:@"TRUE" handler:^(NSError* error3) {
                        if(error || error2 || error3) {
                            NSLog(@"%@ Error: Unable to get friends profiles - %@ %@ %@", NSStringFromSelector(_cmd), error, error2, error3);
                        }
                    }];
                }];
            }];
        }
        handler(NULL);
    }];
}
     
// After SSO, redirect sends app here to begin
- (void)handleOpenURL:(NSURL *)url
{
    [self setImAnonymousStatus:FALSE];

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

#ifdef TEST_SERVER
        [PPManager sharedInstance].expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:200];  // cause token to renew @ 1/2 expiration period
#else
        [PPManager sharedInstance].expirationTime = [[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"] ? [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 12)] : [[NSDate alloc] initWithTimeIntervalSinceNow:(1)];  // cause token to renew @ 1/2 expiration period

#endif
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
    if([PPManager sharedInstance].refreshToken == nil) {
        NSLog(@"%@  ERROR attempting to refresh token with nil refreshToken: %@", NSStringFromSelector(_cmd));
    }
    NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @"refresh_token",@"grant_type",
                           [PPManager sharedInstance].clientId,@"client_id",
                           [PPManager sharedInstance].clientSecret,@"client_secret",
                           [PPManager sharedInstance].refreshToken,@"refresh_token",
                           nil ];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url.absoluteString parameters:parms progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"%@  responseObject: %@", NSStringFromSelector(_cmd), responseObject);
        [PPManager sharedInstance].refreshToken = [responseObject objectForKey:@"refresh_token"];
        [PPManager sharedInstance].accessToken = [responseObject objectForKey:@"access_token"];
        [PPManager sharedInstance].tokenType = [responseObject objectForKey:@"token_type"];
        NSInteger delta = 10000000;
        if([[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"]) {
#ifdef TEST_SERVER
            delta = 200;
#else
            delta = 3600 * 11;
#endif
        }

        [PPManager sharedInstance].expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:delta];
        [self storeTokensInKeychain];
        handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        handler(error);
    }];
}

- (void)extractAndSaveTokens:(NSDictionary*)d
{
    [PPManager sharedInstance].refreshToken = [d objectForKey:@"refresh_token"];
    [PPManager sharedInstance].accessToken = [d objectForKey:@"access_token"];
    [PPManager sharedInstance].tokenType = [d objectForKey:@"token_type"];
#ifdef TEST_SERVER
    [PPManager sharedInstance].expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:(200)];  // cause token to renew @ 1/2 expiration period
#else
    [PPManager sharedInstance].expirationTime = ([[d objectForKey:@"expires_in"] isEqualToString:@"1d"] || [[d objectForKey:@"access_token_expires_in"] isEqualToString:@"1d"]) ? [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 12)] : [[NSDate alloc] initWithTimeIntervalSinceNow:(1)];  // cause token to renew @ 1/2 expiration period
#endif
    [PPManager sharedInstance].managerStatus = PPStatusOnline;
    [self storeTokensInKeychain];
}

- (void)storeTokensInKeychain {
    [[PDKeychainBindings sharedKeychainBindings] setObject:_refreshToken forKey:@"refresh_token"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:_accessToken forKey:@"access_token"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:[[PPManager sharedInstance] stringFromNSDate:[PPManager sharedInstance].expirationTime] forKey:@"expiration_time"];
}


- (void)isAuthenticated:(void(^)(BOOL isAuthenticated, NSError*  error))handler
{
//    NSString* rt = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"refresh_token"];
//    NSString* at = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"access_token"];
//    NSString* et = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"];
//    NSString* ac = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"auth_code"];
//    NSLog(@"%@ keychain parms: rt:%@  at:%@  et:%@  ac:%@", NSStringFromSelector(_cmd), rt, at, et, ac);
    if([self allTokensExist]) {
        if ([[PPManager sharedInstance] tokensNotExpired]) {
//            [PPManager sharedInstance].refreshToken = [PPManager sharedInstance].refreshToken;
//            [PPManager sharedInstance].accessToken = [PPManager sharedInstance].accessToken;
            handler(TRUE, NULL);
        } else {
            NSLog(@"%@ access token expired: et:%@", NSStringFromSelector(_cmd), [PPManager sharedInstance].expirationTime);
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
    if([[NSDate dateWithTimeIntervalSinceNow:0] compare: [[PPManager sharedInstance] dateFromString:[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"]]] == NSOrderedAscending) {
        return TRUE;
    } else {
        NSLog(@"%@ Expired token: expiration_time: %@\n", NSStringFromSelector(_cmd), [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"expiration_time"]);
        NSLog(@"%@ present time: %@\n", NSStringFromSelector(_cmd), [NSDate dateWithTimeIntervalSinceNow:0]);
        return FALSE;
    };
}
         
-(void)logout {
    [PPManager sharedInstance].accessToken = NULL;
    [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"auth_code"];
    [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"access_token"];
    if(([self getImAnonymousStatus]) == FALSE) {
        [PPManager sharedInstance].refreshToken = NULL;
        [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"refresh_token"]; // allow anonymous user to relogin w/o creating new acct
        [PPManager sharedInstance].expirationTime = NULL;
        [[PDKeychainBindings sharedKeychainBindings] setObject:NULL forKey:@"expiration_time"];
    }
}


- (NSString *)getDeviceToken
{
    return @"unknown";
}

- (NSDate*)dateFromString:(NSString*)datestring
{
    NSDateFormatter* rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [rfc3339DateFormatter dateFromString:datestring];
}

- (NSString *)stringFromNSDate:(NSDate*)date
{
    NSDateFormatter* rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [rfc3339DateFormatter stringFromDate:date];
}

- (NSString *)dateStringFromAge:(int)age {
    [[PPManager sharedInstance] captureAge:[NSString stringWithFormat:@"%d",age]];
    NSDate *now = [NSDate date];
    NSDateComponents *minusAge = [NSDateComponents new];
    minusAge.year = -1*age;
    NSDate *birthDate = [[NSCalendar currentCalendar] dateByAddingComponents:minusAge
                                                                            toDate:now
                                                                           options:0];
    return [[PPManager sharedInstance] stringFromNSDate:birthDate];
}


-(NSString*)getAge
{
    [PPManager sharedInstance].PPuserobj.myAge = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"user_age"];
    return [PPManager sharedInstance].PPuserobj.myAge;
}
- (NSInteger)getAgeInt
{
    return [[self getAge] intValue];
}

-(void)captureAge:(NSString*)age
{
    if(age) [[PDKeychainBindings sharedKeychainBindings] setObject:age forKey:@"user_age"];
}
- (void)setImAnonymousStatus:(Boolean)imAnonymous
{
    [[PDKeychainBindings sharedKeychainBindings] setObject:imAnonymous?@"TRUE":@"FALSE" forKey:@"user_is_anonymous"];
}
- (Boolean)getImAnonymousStatus
{
    return ([[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"user_is_anonymous"] isEqualToString:@"TRUE"]? TRUE:FALSE);
}
@end


