//
//  NSObject+HJRequest.m
//  HJNetworkDemo
//
//  Created by terrywang on 2017/6/29.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import "NSObject+HJRequestConfig.h"
#import "HJNetwork.h"
#import "NSError+HJError.h"
#import "YYModel.h"

static NSString *const kJKCodeKey   = @"code";
static NSString *const kJKErrorKey  = @"error";
static NSString *const kJKResultKey = @"result";

#define JKSystemErrorDomain   @"jk.system.error.domain"
#define JKLogicErrorDomain    @"jk.logic.error.domain"
#define JKAPIDataErrorDomain  @"jk.apidata.error.domain"

#pragma mark - 接口验证用户名密码
#define BaseAuthenticationUserName  @"suixindai"
#define BaseAuthenticationPassword  @"1qaz!@#$"

@implementation NSObject (HJRequest)

+ (void)hj_setupRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer {
    //TODO:
    NSDictionary *dict = @{@"X-DeviceToken":@"FC8A3038-B7BE-48B6-B8A7-456B2592119B",
                           @"X-Idfa":@"0F858282-8D72-4DD9-9E0B-CCEDA09E839F",
                           @"X-Ip":@"00000000-0000-0000-0000-000000000000",
                           @"os":@"iOS",
                           @"version":@"5.1",
                           @"User-Agent":@"",
                           @"app-bundle-id":@"",
                           @"groupId":@"2",
                           @"pid":@"10002",
                           @"bundleId":@"me.ImmediatelyLoan.app",
                           @"terminalId":@"2",
                           @"token":@"",
                           @"app-bundle-id":@"me.ImmediatelyLoan.app"
                           };
    
    requestSerializer.timeoutInterval = 20;
    [requestSerializer setAuthorizationHeaderFieldWithUsername:BaseAuthenticationUserName password:BaseAuthenticationPassword];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

+ (void)hj_setupResponseSerializer:(AFHTTPResponseSerializer *)responseSerializer {
    responseSerializer.acceptableContentTypes = [responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"text/plain"]];
}

+ (NSString *)hj_APIServer {
    return @"http://172.16.0.141:10014/gateway/";
}

/**
 对请求参数做签名
 
 @param paramters 需要签名的参数字典
 @return 返回签名后的参数字典
 */
+ (NSDictionary *)hj_signParameters:(NSDictionary *)paramters {
    //TODO:
    return paramters;
}

+ (void)hj_receiveResponseObject:(id)responseObject
                            task:(NSURLSessionDataTask *)task
                           error:(NSError *)error
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    if (error) {
        
        // 断网不发送
        if (error.code != kCFURLErrorNotConnectedToInternet) {
        }
        
        if (failure) {
            //-------VIP--------BEGIN
            failure(nil, [NSError hj_handleSystemError:error]);
            //-------VIP--------END
        }
        return;
    }
    
    NSString *code = [responseObject objectForKey:kJKCodeKey];
    if (code && [code isEqualToString:@"success"]) {
        //success
        id result = [responseObject objectForKey:kJKResultKey];
        if (!result) {
            result = nil;
        }
        if (success) {
            success(task, result);
        }
        return;
    }
    
    //-------VIP--------BEGIN
    id aError = [responseObject objectForKey:kJKErrorKey];
    if (aError && ![aError isEqual:[NSNull null]]) {
        if ([aError isKindOfClass:[NSDictionary class]]) {
            
            // 断网不发送
            if (error.code != kCFURLErrorNotConnectedToInternet) {
                
                
                if ([code isKindOfClass:[NSString class]]
                    && [error.domain isEqualToString:JKSystemErrorDomain]
                    ){
                }
            }
            
            if (failure) {
                //这里重新包装LNError
                //code 为空，则代表是老接口格式，否则是新接口格式
                failure(nil, code ? [NSError hj_handleLogicError:aError] : [NSError hj_handleLogicError:aError]);
            }
        } else {
            if (failure) {
                failure(nil, code ? [NSError hj_handleApiDataError] : [NSError hj_handleApiDataError]);
            }
        }
        return;
    }
    //-------VIP--------END
    
    id result = [responseObject objectForKey:kJKResultKey];
    
    if (!result || [result isEqual:[NSNull null]]) {
        result = nil;
    }
    if (success) {
        success(task, result);
    }
}

+ (id)hj_parseResponseObject:(id)responseObject {
    if (!responseObject || [responseObject isEqual:[NSNull null]]) {
        return nil;
    } else if ([responseObject isKindOfClass:[NSArray class]]) {
        if (self != [NSString class] && self != [NSNumber class]) {
            return [NSArray yy_modelArrayWithClass:self json:responseObject];
        }
    } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
        return [self yy_modelWithJSON:responseObject];
    }
    return nil;
}

+ (BOOL)hj_DebugLog {
    return YES;
}

@end
