//
//  PPDataService.h
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDataService : NSObject

-(void)openBucket:(NSString*)bucketName andUsers:(NSArray*)users handler:(void(^)(NSError* error))handler;
-(void)createBucket:(NSString*)bucketName andUsers:(NSArray*)users handler:(void(^)(NSError* error))handler;
-(void)writeBucket:(NSString*)bucketName andKey:(NSString*)key andValue:(NSString*)value push:(BOOL)push handler:(void(^)(NSError* error))handler;
-(void)readBucket:(NSString*)bucketName andKey:(NSString*)key handler:(void(^)(NSDictionary* d, NSError* error))handler;
-(void)readAllFromBucket:(NSString*)bucketName handler:(void(^)(NSDictionary *d, NSError *error))handler;
-(void)deleteFromBucket:(NSString*)bucketName andKey:(NSString*)key;
-(void)emptyBucket:(NSString*)bucketName;
-(void)registerForBucketContentChanges:(NSString*)bucketName callback:(void(^)(NSDictionary* d))callback;

@end



