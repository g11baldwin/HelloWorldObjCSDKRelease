//
//  AppDelegate.m
//  HelloWorld
//
//  Created by JettBlack on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "PPManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	// Replace these variables with the values from
	// the playPORTAL Partner Dashboard
	NSString *clientId = @"<YOUR CLIENTID HERE>";
	NSString *clientSecret = @"<YOUR CLIENT SECRET HERE>";
	
	// Add helloworld://redirect as a rediectURI
	// for the App in the playPORTAL Partner Dashboard
	NSString *redirectURI = @"helloworld://redirect";
	
	[[PPManager sharedInstance] configure:clientId secret:clientSecret andRedirectURI:redirectURI];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[[PPManager sharedInstance] handleOpenURL:url];
	return true;
}

@end
