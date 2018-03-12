//
//  PPDataService.m
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
// The data service provides methods for:
// - managing storage of arbitrary data (create/read/write/delete storage buckets)
// - getting stored images (jpeg)
#import "PPManager.h"
#import "PPDataService.h"
#import "AFNetworking.h"

@implementation PPDataService

// Either creates a new bucket or joins an existing bucket
-(void)openBucket:(NSString*)bucketName andUsers:(NSArray*)users handler:(void(^)(NSError* error))handler
{
    if(bucketName && users && users.count) {
        // do a GET from the bucketName to see if it exists (or not)
        [self readBucket:bucketName andKey:nil handler:^(NSDictionary* d, NSError* error) {
            if(d) {
                NSLog(@"%@ User bucket %@ already exists and is opened: %@", NSStringFromSelector(_cmd), bucketName, error);
                handler(NULL); // bucket exists
            } else { // create one
                [self createBucket:bucketName andUsers:users handler:^(NSError* error) {
                    if(error) NSLog(@"%@ Error: dang... bucket problems! %@", NSStringFromSelector(_cmd), error);
                }];
            }
        }];
        
    } else {
        handler([NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

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

// Read either the entire bucket (if Key=nil) - Returns a dictionary containing a data object (that can contain unspecified structure)
// Read a single KV pair - Returns a dictionary containing a single pair  Ex: d = { thekey:thevalue };
-(void)readBucket:(NSString*)bucketName andKey:(NSString*)key handler:(void(^)(NSDictionary* d, NSError* error))handler
{
//    if(bucketName && key) {
    if(bucketName) {

        NSLog(@"%@ reading from bucket %@", NSStringFromSelector(_cmd), bucketName);
        NSString *urlString;
        if(key) {
            urlString = [NSString stringWithFormat:@"%@/%@%@%@%@%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket", @"?id=", bucketName, @"&key=", key];
        } else {
            urlString = [NSString stringWithFormat:@"%@/%@%@%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket", @"?id=", bucketName];
        }
        [[PPManager buildAF] GET:[NSURL URLWithString:urlString].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            handler([[NSMutableDictionary alloc]initWithDictionary:key?[responseObject valueForKeyPath:@"data"]:responseObject], NULL);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
            handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
        }];
    } else {
        handler(NULL, [NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:01 userInfo:NULL]);
    }
}

// Deleta KV pair from the bucket (by writing a K:NULL pair)
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
-(void)emptyBucket:(NSString*)bucketName handler:(void(^)(NSError *error))handler
{
    if(bucketName) {
        __block NSMutableArray* userlist = [[NSMutableArray alloc] init];
        [self readBucket:bucketName andKey:nil handler: ^(NSDictionary* d, NSError* error) {
            for (NSArray *object in [d objectForKey:@"users"]) {
                [userlist addObject:object];
            }
            
            [self deleteBucket:bucketName handler: ^(NSError* error) {
                if(!error) {
                    [self createBucket:bucketName andUsers:userlist handler:^(NSError* error) {
                        if(error) NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
                        handler(NULL);
                    }];
                } else {
                    handler(NULL);
                }
            }];
        }];
    }
}

// Removes a bucket
-(void)deleteBucket:(NSString*)bucketName handler:(void(^)(NSError *error))handler
{
    if(bucketName) {
        /*
         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket"]];
         NSDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys: bucketName,@"id", nil ];
         AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
         [manager DELETE:url.absoluteString parameters:parms success:^(NSURLSessionDataTask *task, id responseObject) {
         NSLog(@"%@ responseObject: %@", NSStringFromSelector(_cmd), responseObject);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
         NSLog(@"%@ Error %@", NSStringFromSelector(_cmd), error);
         }];
         */
        
        
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [PPManager sharedInstance].apiUrlBase, @"app/v1/bucket"];
        NSDictionary *body = @{@"id":bucketName, @"access_token": [[PPManager sharedInstance] getAccessToken]};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"DELETE" andUrlString:urlString];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);
                handler(NULL);
            } else {
                NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
                handler(error);
            }
        }] resume];
    }
}


// Register a callback function that is invoked on bucket content changes.
-(void)registerForBucketContentChanges:(NSString*)bucketName callback:(void(^)(NSDictionary* d))callback
{
    callback([NSMutableDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:@"com.dynepic.playportal-sdk" code:99 userInfo:NULL], @"error", nil]);
}


-(UIImage*) getImage:(NSString*) imageId
{
    if(!imageId) return NULL;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", [PPManager sharedInstance].apiUrlBase, @"user/v1/static", imageId];
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

@end
