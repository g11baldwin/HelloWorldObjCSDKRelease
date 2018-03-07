//
//  PPDataService.m
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "PPManager.h"
#import "PPDataService.h"
#import "AFNetworking.h"

@implementation PPDataService

// Create a new bucket or join to an existing bucket
-(void)createBucket:(NSString*)bucketName andUsers:(NSArray*)users handler:(void(^)(NSError* error))handler
{
    if(bucketName && users && users.count) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket"];
        NSDictionary *body = @{@"public":@"FALSE", @"id":bucketName, @"users":users, @"data":@{@"id":[[[PPManager sharedInstance]PPusersvc] getMyId]}, @"access_token": [[PPManager sharedInstance] getAccessToken]};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"PUT" andUrlString:urlString];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);
            } else {
                NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
            }
        }] resume];
    } else {
        handler([NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

// Upserts a single KV pair
-(void)writeBucket:(NSString*)bucketName andKey:(NSString*)key andValue:(NSString*)value push:(BOOL)push handler:(void(^)(NSError* error))handler
{
    if(bucketName && key && value) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket"];
        NSDictionary *body = @{@"id":bucketName, @"key":key, @"value":value, @"access_token": [[PPManager sharedInstance] getAccessToken]};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"POST" andUrlString:urlString];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);
            } else {
                NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
            }
        }] resume];
    } else {
        handler([NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

// Read a single KV pair
-(void)readBucket:(NSString*)bucketName andKey:(NSString*)key handler:(void(^)(NSDictionary* d, NSError* error))handler
{
    if(bucketName && key) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@%@%@%@%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket", @"?id=", bucketName, @"&key=", key];
        [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            handler([[NSMutableDictionary alloc]initWithDictionary:responseObject], NULL);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
            handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
        }];
    } else {
        handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

// Read all contents from the bucket
-(void)readAllFromBucket:(NSString*)bucketName handler:(void(^)(NSDictionary *d, NSError *error))handler
{
    if(bucketName) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@%@%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket", @"?id=", bucketName];
        [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            handler([[NSMutableDictionary alloc]initWithDictionary:responseObject], NULL);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
            handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
        }];
    } else {
        handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

// Deleta a KV pair from the bucket (by writing a K:NULL pair)
-(void)deleteFromBucket:(NSString*)bucketName andKey:(NSString*)key
{
    if(bucketName && key) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket"];
        NSDictionary *body = @{@"id":bucketName, @"key":key, @"": @"value", @"access_token": [[PPManager sharedInstance] getAccessToken]};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"GET" andUrlString:urlString];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);
            } else {
                NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
            }
        }] resume];
    }
}

// Deleta all KV pairs from the bucket.
-(void)emptyBucket:(NSString*)bucketName
{
    if(bucketName != nil) {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"bucket"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"garybucket-1",@"id", nil ];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager DELETE:url.absoluteString parameters:parms success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"%@ responseObject: %@", NSStringFromSelector(_cmd), responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
        }];
    }
}

// Register a callback function that is invoked on bucket content changes.
-(void)registerForBucketContentChanges:(NSString*)bucketName callback:(void(^)(NSDictionary* d))callback
{
    callback([NSMutableDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:99 userInfo:NULL], @"error", nil]);
}

@end
