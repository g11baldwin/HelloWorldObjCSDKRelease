//
//  AppDelegate.m
//  HelloWorld
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "PPManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//TODO: comments
NSString *cid = @"iok-cid-96252d9d5cc697e94af09676f130d646931b1f3ee9d54492";
NSString *cse = @"iok-cse-d11ea79c8ed30200c74644cdb7423ffef0ea5a35a44e678c";
NSString *redirectURI = @"helloworld://redirect";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[[PPManager sharedInstance] configure:cid secret:cse andRedirectURI:redirectURI];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[[PPManager sharedInstance] handleOpenURL:url];
	return true;
}

@end
