//
//  NSObject+HJNetworkModelAccess.m
//  HJNetworkExample
//
//  Created by terrywang on 2017/7/12.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import "NSObject+HJNetworkModelAccess.h"

@implementation NSObject (HJNetworkModelAccess)

#pragma mark - Model

+ (NSURLSessionDataTask *)hj_requestModelAPI:(nonnull NSString *)api
                                  parameters:(nullable NSDictionary *)parameters
                                  completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_requestModelAPI:api method:HTTP_POST parameters:parameters completion:completion];
}

+ (NSURLSessionDataTask *)hj_requestModelAPI:(NSString *_Nonnull)api
                                      method:(HTTP_METHOD)method
                                  parameters:(NSDictionary *_Nullable)parameters
                                  completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_requestModelAPI:api method:method headers:nil parameters:parameters completion:completion];
}

+ (NSURLSessionDataTask *)hj_requestModelAPI:(nonnull NSString *)api
                                      method:(nonnull HTTP_METHOD)method
                                     headers:(nullable NSDictionary *)headers
                                  parameters:(nullable NSDictionary *)parameters
                                  completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_requestAPI:api
                        method:method
                       headers:headers
                    parameters:parameters
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull data) {
                           if (completion) {
                               completion([self hj_parseResponseObject:data], nil);
                           }
                       } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                           if (completion) {
                               completion(nil, error);
                           }
                       }];
}

+ (NSURLSessionDataTask *)hj_uploadModelAPI:(NSString *)api
                                    headers:(NSDictionary *)headers
                                 parameters:(NSDictionary *)parameters
                  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                   progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                                 completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_uploadAPI:api
                      headers:headers
                   parameters:parameters
    constructingBodyWithBlock:block
                     progress:uploadProgress
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull data) {
                          if (completion) {
                              completion([self hj_parseResponseObject:data], nil);
                          }
                      } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                          if (completion) {
                              completion(nil, error);
                          }
                      }];
}

+ (NSURLSessionDataTask *)hj_requestJsonModelAPI:(NSString *_Nonnull)api
                                         headers:(NSDictionary *_Nullable)headers
                                        httpBody:(NSData *)httpBody
                                      completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_requestJsonModelAPI:api
                                headers:headers
                               httpBody:httpBody
                             parameters:nil
                         uploadProgress:nil
                       downloadProgress:nil
                             completion:completion];
}

+ (NSURLSessionDataTask *)hj_requestJsonModelAPI:(NSString *_Nonnull)api
                                         headers:(NSDictionary *_Nullable)headers
                                        httpBody:(NSData *)httpBody
                                      parameters:(NSDictionary *_Nullable)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                      completion:(void (^)(id responseObject, NSError *error))completion {
    return [self hj_requestJsonAPI:api
                            method:HTTP_POST
                           headers:headers
                          httpBody:httpBody
                        parameters:parameters
                    uploadProgress:uploadProgress
                  downloadProgress:downloadProgress
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull data) {
                               if (completion) {
                                   completion([self hj_parseResponseObject:data], nil);
                               }
                           } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                               if (completion) {
                                   completion(nil, error);
                               }
                           }];
}

@end
