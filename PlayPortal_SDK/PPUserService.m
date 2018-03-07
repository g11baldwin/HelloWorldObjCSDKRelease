//
//  PPUserService.m
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "PPUserService.h"
#import "PPManager.h"
#import "AFNetworking.h"
#import "AFImageDownloader.h"
#import "UIImageView+AFNetworking.h"
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


// return full user profile (if unable to get latest, provide a cached version if it exists)
- (void)getProfile: (void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile"];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        _userDictionary = responseObject;
		NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
		[self dismissSafari];
		self.addUserListener(user, NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        if(_userDictionary == nil) {
			[self dismissSafari];
			self.addUserListener(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
        } else {
			[self dismissSafari];
			self.addUserListener(_userDictionary, NULL);
        }
    }];
}

- (UIImage*)getProfilePic
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile/picture"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFImageDownloader *d = [[AFImageDownloader alloc] init];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: @"GET" URLString:[NSString stringWithString:urlString] parameters:nil error:nil];
    NSString *btoken = [NSString stringWithFormat:@"%@ %@", @"Bearer", [PPManager sharedInstance].accessToken];
    [req setValue:btoken forHTTPHeaderField:@"Authorization"];
    
    NSData *imageData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
    
    
//    [d downloadImageForURLRequest:req  success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
//        NSLog(@"response:%@", response);
////        handler(responseObject, NULL);
////        return responseObject;
//    } failure:^(NSURLRequest *request , NSHTTPURLResponse *_Nullable response , NSError *error) {
//        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
////        handler(NULL, error);
////        return NULL;
//    }];
}

- (NSString*)getMyId
{
    return (_userDictionary != nil) ? [_userDictionary valueForKey:@"userId"] : @"0";
}
- (NSString*)getMyUsername
{
    return (_userDictionary != nil) ? [_userDictionary valueForKey:@"handle"] : @"unknown";
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
