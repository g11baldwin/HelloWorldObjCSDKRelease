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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	//Replace these with the values your generated on the playPORTAL Partner Dashboard
	NSString *cid = @"iok-cid-e1fa99fb361123b78cb6bcafcd639fb49c31766bc3eddf94";
	NSString *cse = @"iok-cse-1778988ca3843a3c227c3fa5ced3be62d359a0aa87a169d5";
	NSString *redirectURI = @"helloworld://redirect";
	[[PPManager sharedInstance] configure:cid secret:cse andRedirectURI:redirectURI];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[[PPManager sharedInstance] handleOpenURL:url];
	return true;
}

@end
