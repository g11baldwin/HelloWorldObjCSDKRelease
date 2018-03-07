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

@interface PPManager()

@property (readwrite, nonatomic, copy) NSString* oauthURL;
@property (readwrite, nonatomic, copy) NSString* refreshToken;
@property (readwrite, nonatomic, copy) NSString* tokenType;
@property (readwrite, nonatomic, copy) NSString* apiOauthBase;
@property (readwrite, nonatomic, copy) NSString* authCode;
@property (readwrite, nonatomic, copy) NSDate* expirationTime;

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
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"image/jpg"];

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
    }
}

// After SSO, redirect sends app here to begin
- (void)handleOpenURL:(NSURL *)url
{
#pragma FIXME // add check for URI redirect content
    
    NSArray *strs = [url.absoluteString componentsSeparatedByString:@"="];
    if(strs.count >= 3) {
        NSArray *substrs = [strs[1] componentsSeparatedByString:@"&"];
        [PPManager sharedInstance].authCode = substrs[0];
		[[PPManager sharedInstance] getInitialToken:^(NSError *error){
			if (error) {
				NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
			} else {
				[[PPManager sharedInstance].PPusersvc getProfile:^(NSError *error){
					if (error) {
						NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);
					}
					UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
					while (topController.presentedViewController) {
						topController = topController.presentedViewController;
					}
					[topController dismissViewControllerAnimated:true completion:NULL];
				}];
			}
		}];
    }
}

// After SSO auth, get an access token for validating API requests
- (void)getInitialToken:(void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiOauthBase, @"token"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @"authorization_code",@"grant_type",
                           [PPManager sharedInstance].authCode,@"code",
                           [PPManager sharedInstance].redirectURI,@"redirect_uri",
                           [PPManager sharedInstance].clientId,@"client_id",
                           [PPManager sharedInstance].clientSecret,@"client_secret",
                           nil ];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url.absoluteString parameters:parms progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"%@  responseObject: %@", NSStringFromSelector(_cmd), responseObject);
        [PPManager sharedInstance].refreshToken = [responseObject objectForKey:@"refresh_token"];
        [PPManager sharedInstance].accessToken = [responseObject objectForKey:@"access_token"];
        [PPManager sharedInstance].tokenType = [responseObject objectForKey:@"token_type"];
        [PPManager sharedInstance].expirationTime = [[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"] ? [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 23)] : [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 1)];
        [PPManager sharedInstance].managerStatus = PPStatusOnline;
		handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
		handler(error);
    }];
}

- (void)refreshAccessToken
{
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
        [PPManager sharedInstance].expirationTime = [[responseObject objectForKey:@"expires_in"] isEqualToString:@"1d"] ? [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 23)] : [[NSDate alloc] initWithTimeIntervalSinceNow:(3600 * 1)];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
    }];
}

#pragma FIXME // move tokens to keychain
- (BOOL)isAuthenticated
{
    if(([PPManager sharedInstance].refreshToken == nil) || ([PPManager sharedInstance].accessToken == nil)) {
        return FALSE;
    } else {
        [[PPManager sharedInstance] refreshAccessToken];
        return TRUE;
    }
}
-(void)logout {
	[PPManager sharedInstance].refreshToken = NULL;
	[PPManager sharedInstance].accessToken = NULL;
}


@end


