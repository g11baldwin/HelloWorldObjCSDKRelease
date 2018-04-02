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
//    }
	
}

- (void)loginAnonymously:(NSDate *)birthdate
{
    NSLog(@"%@ app user logging in anonymously...", NSStringFromSelector(_cmd));
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile"];
    [[PPManager sharedInstance] setImAnonymousStatus:TRUE];

    // PUT /my/profile
    //
    // REQUEST
    // body: {
    //   anonymous: true (required),
    //   dateOfBirth: number,
    //   clientId: String,
    //   deviceToken?: String
    // },
    // headers: {
    //   accesstoken: String
    // }
    
        NSDictionary *body = @{@"anonymous":@"TRUE", @"dateOfBirth": [PPManager stringFromNSDate:birthdate], @"clientId":[PPManager sharedInstance].clientId, @"deviceToken": [[PPManager sharedInstance] getDeviceToken]};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"PUT" andUrlString:urlString];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *dictionary = [(NSHTTPURLResponse*)response allHeaderFields]; // Capture accessToken and refreshToken from header
                [[PPManager sharedInstance] extractAndSaveTokens:dictionary];
                NSLog(@"%@ response: %@", NSStringFromSelector(_cmd), dictionary);
                NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);

                NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                [[PPManager sharedInstance].PPuserobj inflateWith:user];

                [[PPManager sharedInstance].PPdatasvc openBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andUsers:(NSArray *)[NSArray arrayWithObjects:[PPManager sharedInstance].PPuserobj.userId, nil] public:@"FALSE" handler:^(NSError* error) {
                    if(error) {
                        NSLog(@"%@ Error: Unable to open/create user bucket - %@", NSStringFromSelector(_cmd), error);
                        [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
                    } else {
                        NSLog(@"%@ Open/create user bucket for user: %@", NSStringFromSelector(_cmd), user);
                        [PPManager sharedInstance].PPusersvc.addUserListener([PPManager sharedInstance].PPuserobj, NULL);
                    }
                }];
            } else {
                [PPManager processAFError:error withRetryBlock:NULL];
                NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
                [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
            }
        }] resume];
}


-(void)logout
{
	[[PPManager sharedInstance] logout];
}

- (void)getProfile: (void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/profile"];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        _userDictionary = responseObject;
        NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
        [[PPManager sharedInstance].PPuserobj inflateWith:user];
        handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [PPManager processAFError:error withRetryBlock:^{
            [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject2) {
                NSLog(@"%@ Retry block %@ ", NSStringFromSelector(_cmd), responseObject2);
                _userDictionary = responseObject2;
                NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject2];
                [[PPManager sharedInstance].PPuserobj inflateWith:user];
                handler(NULL);
            } failure:^(NSURLSessionTask *operation, NSError *error2) {
                NSLog(@"%@ Retry block Error %@", NSStringFromSelector(_cmd), error2);
                handler(error2);
            }];
        }];
      }];
}

- (void)getFriendsProfiles:(void(^)(NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/my/friends"];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSMutableArray *myfriends = [NSArray arrayWithObjects:responseObject, nil];
        [[PPManager sharedInstance].PPfriendsobj inflateFriendsList:myfriends];
         handler(NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [PPManager processAFError:error withRetryBlock:^{
            [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject2) {
                NSLog(@"%@ Retry block %@ ", NSStringFromSelector(_cmd), responseObject2);
                NSMutableArray *myfriends2 = [NSArray arrayWithObjects:responseObject2, nil];
                [[PPManager sharedInstance].PPfriendsobj inflateFriendsList:myfriends2];
                handler(NULL);
            } failure:^(NSURLSessionTask *operation, NSError *error2) {
                NSLog(@"%@ Retry block Error %@", NSStringFromSelector(_cmd), error2);
                handler(error2);
            }];
        }];
        
        
        
        [PPManager processAFError:error withRetryBlock:NULL];
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        handler(error);
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

- (void)searchForUsers:(NSString*)matchingString handler:(void(^)(NSArray* matchingUsers, NSError *error))handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?term=%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/search", matchingString];
    [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *usersMatchingSearch = [NSArray arrayWithObjects:responseObject, nil];
        handler(usersMatchingSearch, NULL);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [PPManager processAFError:error withRetryBlock:NULL];
        NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        handler(NULL, error);
    }];
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
