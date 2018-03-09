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


    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
