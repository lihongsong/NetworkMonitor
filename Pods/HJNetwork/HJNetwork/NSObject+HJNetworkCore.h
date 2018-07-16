//
//  NSObject+HJNetworkCore.h
//  HJNetworkExample
//
//  Created by terrywang on 2017/7/12.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "HJNetworkProtocol.h"

typedef NSString *HTTP_METHOD;

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT HTTP_METHOD const HTTP_POST;
FOUNDATION_EXPORT HTTP_METHOD const HTTP_GET;
FOUNDATION_EXPORT HTTP_METHOD const HTTP_PUT;
FOUNDATION_EXPORT HTTP_METHOD const HTTP_DELETE;
FOUNDATION_EXPORT HTTP_METHOD const HTTP_HEAD;
FOUNDATION_EXPORT HTTP_METHOD const HTTP_PATCH;

@interface NSObject (HJNetworkCore) <HJNetworkProtocol>


+ (NSURLSessionDataTask *)hj_requestAPI:(NSString *_Nonnull)api
                                 method:(NSString *_Nullable)method
                                headers:(NSDictionary *_Nullable)headers
                             parameters:(NSDictionary *_Nullable)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (NSURLSessionDataTask *)hj_uploadAPI:(NSString *_Nonnull)api
                               headers:(NSDictionary *_Nullable)headers
                            parameters:(NSDictionary *_Nullable)parameters
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                              progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (NSURLSessionDataTask *)hj_requestJsonAPI:(NSString *_Nonnull)api
                                     method:(NSString *_Nullable)method
                                    headers:(NSDictionary *_Nullable)headers
                                   httpBody:(NSData *)httpBody
                                 parameters:(NSDictionary *_Nullable)parameters
                             uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                           downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
NS_ASSUME_NONNULL_END
