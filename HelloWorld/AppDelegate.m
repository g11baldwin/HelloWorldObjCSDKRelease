//
//  AppDelegate.m
//  HelloWorld
//
//  Created by Jett Black on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <PlayPortal/PPManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Replace these with the values your generated on the playPORTAL Partner Dashboard
    NSString *cid = @"YOUR_CLIENT_ID_HERE";
    NSString *cse = @"YOUR_CLIENT_SECRET_HERE";

    // This is the redirect that you entered in to the playPORTAL Partner Dashboard
    NSString *redirectURI = @"helloworld://redirect";
    [[PPManager sharedInstance] configure:cid secret:cse andRedirectURI:redirectURI];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[PPManager sharedInstance] handleOpenURL:url];
    return true;
}

@end
