//
//  PPUserService.m
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "PPUserService.h"
#import "PPDataService.h"
#import "PPManager.h"
#import "AFNetworking.h"
#import <SafariServices/SafariServices.h>

@interface PPUserService()
@property (readwrite, nonatomic, copy) NSMutableDictionary *userDictionary;
@property (readwrite, nonatomic, copy) SFSafariViewController *svc;
@end

@implementation PPUserService

// If user isn't currently authenticated with server, then perform oauth login
- (void)login
{
	if ([PPManager sharedInstance].managerStatus == PPStatusUnknown) {
		[self dismissSafari];
		self.addUserListener(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
	} else if([[PPManager sharedInstance] isAuthenticated]) {
		NSDictionary* user = [[NSMutableDictionary alloc]initWithDictionary: _userDictionary];
		[self dismissSafari];
		self.addUserListener(user, NULL);
    } else {
		NSString* pre = @"https://sandbox.iokids.net/oauth/signin?client_id=";
		NSString* cid = [PPManager sharedInstance].clientId;
		NSString* mid = @"&redirect_uri=";
		NSString* uri = [PPManager sharedInstance].redirectURI;
		NSString* post = @"&state=beans&response_type=code";
		
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@", pre, cid, mid, uri, post]];

		_svc = [[SFSafariViewController alloc] initWithURL:url];
		_svc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		_svc.modalPresentationStyle = UIModalPresentationOverFullScreen;
		UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
		
		while (topController.presentedViewController) {
			topController = topController.presentedViewController;
		}
		
		[topController presentViewController:_svc animated:YES completion:nil];
    }
	
}

-(void)logout
{
	[[PPManager sharedInstance] logout];
}

- (void)getProfile: (void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile"];
    [self dismissSafari];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        _userDictionary = responseObject;
        NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
        [[PPManager sharedInstance].PPuserobj inflateWith:user];
        self.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
        handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        if([PPManager sharedInstance].PPuserobj == nil) {
            self.addUserListener(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
            handler(error);
        } else {
            self.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
            handler(NULL);
        }
    }];
}

- (void)getFriendsProfiles: (void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/friends"];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        _userDictionary = responseObject;
//        NSDictionary *myfriends = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
        NSArray *myfriends = [NSArray arrayWithObjects:responseObject, nil];
        [[PPManager sharedInstance].PPfriendsobj inflateFriendsList:myfriends];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        if([PPManager sharedInstance].PPuserobj == nil) {
            self.addUserListener(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
        } else {
            self.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
        }
    }];
}
- (UIImage*)getProfilePic:(NSString*)userIdOrimageId
{
    NSString* urlString;
    if([[PPManager sharedInstance].PPuserobj.userId isEqualToString:userIdOrimageId ]) {
        urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile/picture"];
    } else {
            urlString = [NSString stringWithFormat:@"%@/%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/static", userIdOrimageId];
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: @"GET" URLString:[NSString stringWithString:urlString] parameters:nil error:nil];
    NSString *btoken = [NSString stringWithFormat:@"%@ %@", @"Bearer", [PPManager sharedInstance].accessToken];
    [req setValue:btoken forHTTPHeaderField:@"Authorization"];
    
    NSData *imageData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}
- (UIImage*)getCoverPic:(NSString*)userIdOrimageId
{
    NSString* urlString;
    if([[PPManager sharedInstance].PPuserobj.userId isEqualToString:userIdOrimageId ]) {
        urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile/cover"];
    } else {
        urlString = [NSString stringWithFormat:@"%@/%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/static", userIdOrimageId];
    }
   
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: @"GET" URLString:[NSString stringWithString:urlString] parameters:nil error:nil];
    NSString *btoken = [NSString stringWithFormat:@"%@ %@", @"Bearer", [PPManager sharedInstance].accessToken];
    [req setValue:btoken forHTTPHeaderField:@"Authorization"];
    
    // TODO: replace deprecated
    NSData *imageData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

- (NSString*)getMyId
{
    return (_userDictionary != nil) ? [_userDictionary valueForKey:@"userId"] : @"0";
}

- (NSString*)getMyUsername
{
    return (_userDictionary != nil) ? [[PPManager sharedInstance].PPuserobj valueForKey:@"handle"] : @"unknown";
}

-(void)dismissSafari
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if (topController == _svc) {
        [_svc dismissViewControllerAnimated:true completion:NULL];
    }
}

@end
