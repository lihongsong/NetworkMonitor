//
//  NSObject+HJNetworkCore.m
//  HJNetworkExample
//
//  Created by terrywang on 2017/7/12.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import "NSObject+HJNetworkCore.h"

#define HJ_NWLog(fmt, ...) \
if ([NSObject respondsToSelector:@selector(hj_DebugLog)]) { \
BOOL log = [NSObject hj_DebugLog]; \
    if (log) { \
        NSLog((@"\n------------ [HJNetwork] ------------\n" fmt), ##__VA_ARGS__); \
        printf("-------------------------------------\n");\
    }\
}

HTTP_METHOD const HTTP_POST   = @"POST";
HTTP_METHOD const HTTP_GET    = @"GET";
HTTP_METHOD const HTTP_PUT    = @"PUT";
HTTP_METHOD const HTTP_HEAD   = @"HEAD";
HTTP_METHOD const HTTP_DELETE = @"DELETE";
HTTP_METHOD const HTTP_PATCH  = @"PATCH";

@interface AFHTTPSessionManager (Private)

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end

@implementation NSObject (HJNetworkCore)

#pragma mark - Basic
+ (AFHTTPSessionManager *)hj_sessionManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([self respondsToSelector:@selector(hj_setupRequestSerializer:)]) {
        [self hj_setupRequestSerializer:manager.requestSerializer];
    }
    
    if ([self respondsToSelector:@selector(hj_setupResponseSerializer:)]) {
        [self hj_setupResponseSerializer:manager.responseSerializer];
    }
    
    return manager;
}

+ (NSString *)hj_URLStringWithAPI:(NSString *)api {
    NSAssert([self respondsToSelector:@selector(hj_APIServer)], @"+[NSObject hj_APIServer:] must be implementation!");
    return [[self hj_APIServer] stringByAppendingPathComponent:api];
}

+ (NSString *)hj_URLStringForAPI:(NSString *)api
                      parameters:(NSDictionary *)parameters {
    NSString *URLString = [self hj_URLStringWithAPI:api];
    if ([self respondsToSelector:@selector(hj_signParameters:)]) {
        parameters = [self hj_signParameters:parameters];
    }
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray arrayWithCapacity:parameters.count];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [items addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
    }];
    NSURLComponents *components = [NSURLComponents componentsWithString:URLString];
    components.queryItems = items;
    return [components string];
}

+ (NSURLSessionDataTask *)hj_requestAPI:(NSString *_Nonnull)api
                                 method:(NSString *_Nullable)method
                                headers:(NSDictionary *_Nullable)headers
                             parameters:(NSDictionary *_Nullable)parameters
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *URLString = [self hj_URLStringWithAPI:api];
    
    HJ_NWLog(@"URL:%@\nMethod:%@\nHeader:%@\nRequestParams:%@",URLString?:@"",method?:@"",headers?:@"",parameters?:@"");
    
    parameters = [self hj_signParameters:parameters];
    
#ifdef DEBUG
    //    static NSUInteger taskId = 0;
    //    taskId++;
    //    NSInteger curTaskId = taskId;
#endif
    
    //    NSLog(@"request(%zd) %@: %@", taskId, api, parameters);
    AFHTTPSessionManager *manager = [self hj_sessionManager];
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
            
        }];
    }
    
    NSURLSessionDataTask *dataTask;
    //    NSLog(@"--basic-URLString----%@", URLString);
    dataTask = [manager dataTaskWithHTTPMethod:method
                                     URLString:URLString
                                    parameters:parameters
                                uploadProgress:nil
                              downloadProgress:nil
                                       success:^(NSURLSessionDataTask *task, id response) {
                                           [self hj_netWorkReceiveResponseObject:response
                                                                            task:task
                                                                           error:nil
                                                                         success:success
                                                                         failure:failure];
                                       } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           [self hj_netWorkReceiveResponseObject:nil
                                                                            task:task
                                                                           error:error
                                                                         success:success
                                                                         failure:failure];
                                       }];
    
    [dataTask resume];
    return dataTask;
}

+ (NSURLSessionDataTask *)hj_uploadAPI:(NSString *_Nonnull)api
                               headers:(NSDictionary *_Nullable)headers
                            parameters:(NSDictionary *_Nullable)parameters
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                              progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *URLString = [self hj_URLStringWithAPI:api];
    
    parameters = [self hj_signParameters:parameters];
    
    HJ_NWLog(@"URL:%@\nHeader:%@\nRequestParams:%@",URLString?:@"",headers?:@"",parameters?:@"");
    
    AFHTTPSessionManager *manager = [self hj_sessionManager];
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }];
    }
    
    return [manager POST:URLString
              parameters:parameters
constructingBodyWithBlock:block
                progress:uploadProgress
                 success:^(NSURLSessionDataTask *task, id response) {
                     [self hj_netWorkReceiveResponseObject:response
                                                      task:task
                                                     error:nil
                                                   success:success
                                                   failure:failure];
                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                     [self hj_netWorkReceiveResponseObject:nil
                                                      task:task
                                                     error:error
                                                   success:success
                                                   failure:failure];
                 }];
}

+ (NSURLSessionDataTask *)hj_requestJsonAPI:(NSString *_Nonnull)api
                                     method:(NSString *_Nullable)method
                                    headers:(NSDictionary *_Nullable)headers
                                   httpBody:(NSData *)httpBody
                                 parameters:(NSDictionary *_Nullable)parameters
                             uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                           downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *URLString = [self hj_URLStringWithAPI:api];
    
    HJ_NWLog(@"URL:%@\nMethod:%@\nHeader:%@\nRequestParams:%@",URLString?:@"",method?:@"",headers?:@"",parameters?:@"");
    
    parameters = [self hj_signParameters:parameters];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    if ([self respondsToSelector:@selector(hj_setupRequestSerializer:)]) {
        [self hj_setupRequestSerializer:serializer];
    }
    
    NSMutableURLRequest *request = [serializer requestWithMethod:method
                                                       URLString:URLString
                                                      parameters:nil error:nil];
    
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
            [request setValue:value forHTTPHeaderField:key];
        }];
    }
    
    [request setHTTPBody:httpBody];
    
    NSURLSessionDataTask *dataTask;
    dataTask = [manager dataTaskWithRequest:request
                             uploadProgress:uploadProgress
                           downloadProgress:downloadProgress
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                              if (error) {
                                  if (failure) {
                                      [self hj_netWorkReceiveResponseObject:responseObject
                                                                       task:nil
                                                                      error:error
                                                                    success:success
                                                                    failure:failure];
                                  }
                                  return ;
                              }
                              if (success) {
                                  [self hj_netWorkReceiveResponseObject:responseObject
                                                                   task:nil
                                                                  error:nil
                                                                success:success
                                                                failure:failure];
                              }
                          }];
    [dataTask resume];
    return dataTask;
}

+ (void)hj_netWorkReceiveResponseObject:(id)responseObject
                                   task:(NSURLSessionDataTask *)task
                                  error:(NSError *)error
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    HJ_NWLog(@"URL:%@\nResponseObject:%@\nError:%@",task.currentRequest.URL?:@"",responseObject?:@"",error?:@"");
    
    [self hj_receiveResponseObject:responseObject
                              task:task
                             error:error
                           success:success
                           failure:failure];
    
}

@end
