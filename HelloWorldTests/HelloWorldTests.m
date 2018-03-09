//
//  HelloWorldTests.m
//  HelloWorldTests
//
//  Created by blackCloud on 3/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PPManager.h"
#import "PPUserObject.h"
#import "PPUserService.h"
#import "PPDataService.h"

@interface HelloWorldTests : XCTestCase

@end

@implementation HelloWorldTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[PPManager sharedInstance].PPusersvc login];

    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUser
{
    [[PPManager sharedInstance].PPusersvc getProfile:^(NSError *error) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }];
}


- (void)testBucket
{
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    __block NSInteger startingIndex;
    [[PPManager sharedInstance].PPusersvc login];

    NSLog(@"XCT testing : %S", __PRETTY_FUNCTION__);
    [[PPManager sharedInstance].PPusersvc getProfile:^(NSError* error) {
        if(error) {
            NSLog(@"%@ Error: Unable to open/create user bucket - %@", NSStringFromSelector(_cmd), error);
        }
    }];
    
    [[PPManager sharedInstance].PPdatasvc readBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:[NSString stringWithFormat:@"lasttestkey"] handler:^(NSDictionary* d, NSError* error) {
        if(d) {
            NSLog(@"lasttestkey:%@", [d objectForKey:@"lasttestkey"]);
            startingIndex = [[d objectForKey:@"lasttestkey"] intValue];
        } else {
            NSLog(@"ERROR reading lasttestkey");
        }
        for(NSInteger i=startingIndex; i<startingIndex + 10; i++) {
            [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:[NSString stringWithFormat:@"testkey-%ld", i] andValue:[NSString stringWithFormat:@"%ld", i] push:FALSE handler:^(NSError* error) {
                NSLog(@"writing bucket: %@ : %ld", [NSString stringWithFormat:@"testkey-%ld", i], i);
            }];
        }
    }];
    
    [[PPManager sharedInstance].PPdatasvc writeBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andKey:@"lasttestkey" andValue:[NSString stringWithFormat:@"%ld", startingIndex+10] push:FALSE handler:^(NSError *error) {
        if(error) NSLog(@"XCT writeBucket ERROR KV %@:%@", @"lasttestkey", [NSString stringWithFormat:@"%ld", startingIndex+10]);
    }];

    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
