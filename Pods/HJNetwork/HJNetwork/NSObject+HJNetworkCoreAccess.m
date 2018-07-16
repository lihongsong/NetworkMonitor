//
//  NSObject+HJNetworkCoreAccess.m
//  HJNetworkExample
//
//  Created by terrywang on 2017/7/12.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import "NSObject+HJNetworkCoreAccess.h"

@implementation NSObject (HJNetworkCoreAccess)

+ (NSURLSessionDataTask *)hj_requestAPI:(NSString *_Nonnull)api
                             parameters:(NSDictionary * _Nullable)parameters
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    return [self hj_requestAPI:api method:HTTP_POST parameters:parameters success:success failure:failure];
}

+ (NSURLSessionDataTask *)hj_requestAPI:(NSString *_Nonnull)api
                                 method:(HTTP_METHOD _Nullable)method
                             parameters:(NSDictionary *_Nullable)parameters
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    return [self hj_requestAPI:api method:method headers:nil parameters:parameters success:success failure:failure];
}

+ (NSURLSessionDataTask *)hj_uploadAPI:(NSString *_Nonnull)api
                            parameters:(NSDictionary *_Nullable)parameters
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                              progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    return [self hj_uploadAPI:api
                      headers:nil
                   parameters:parameters
    constructingBodyWithBlock:block
                     progress:uploadProgress
                      success:success
                      failure:failure];
}

+ (NSURLSessionDataTask *)hj_requestJsonAPI:(NSString *_Nonnull)api
                                    headers:(NSDictionary *_Nullable)headers
                                   httpBody:(NSData *)httpBody
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    return [self hj_requestJsonAPI:api
                            method:HTTP_POST
                           headers:headers
                          httpBody:httpBody
                        parameters:nil
                    uploadProgress:nil
                  downloadProgress:nil
                           success:success
                           failure:failure];

}

@end
