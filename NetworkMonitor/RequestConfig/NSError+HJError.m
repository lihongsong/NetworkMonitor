//
//  NSError+HJError.m
//  HJNetwork
//
//  Created by terrywang on 2017/6/27.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import "NSError+HJError.h"

@implementation NSError (HJError)

- (NSString *)hj_errorMessage {
    if (!self) {
        return nil;
    }

    NSString *message = nil;
    
    if ([self hj_isSystemError]) {
        if ([self hj_isNetworkIssueError]) {
            //网络错误
            message = HJSystemErrorMessageNetworkIssueMessage;
        } else {
            //其他http异常(包括服务端返回数据异常)
            message = HJSystemErrorMessageUnkownErrorMessage;
        }
    } else if ([self hj_isAPIDataError]) {
        message = self.userInfo[@"message"];
    } else if ([self hj_isLogicError]) {
        //处理token失效
        if ([NSError hj_handleInvalidateToken:self]) {
            return nil;
        }
        
        //处理强制升级
        if ([NSError hj_handleForceUpdate:self]) {
            return nil;
        }

        message = self.userInfo[@"message"];
    }
    
    return message;
}

- (BOOL)hj_isSystemError {
    return [self.domain isEqualToString:HJSystemErrorDomain];
}
    
- (BOOL)hj_isLogicError {
    return [self.domain isEqualToString:HJLogicErrorDomain];
}

- (BOOL)hj_isAPIDataError {
    return [self.domain isEqualToString:HJAPIDataErrorDomain];
}

- (BOOL)hj_isNetworkIssueError {
    return ([self.userInfo[@"errCode"] integerValue] == NSURLErrorNotConnectedToInternet);
}

//处理系统错误，如网络异常
//注意：message为实际的错误信息，方便开发调试。当showError时，会再做一次过滤，用户看到的是过滤后的消息。
+ (NSError *)hj_handleLogicError:(NSDictionary *)error {
    if (error[@"message"]) {
        return [self hj_errorWithDomain:HJLogicErrorDomain
                                     codeString:error[@"errCode"]
                                        message:error[@"message"]];
    }
    return nil;
}

+ (NSError *)hj_handleSystemError:(NSError *)error {
    return [self hj_errorWithDomain:HJSystemErrorDomain
                                 codeString:[NSString stringWithFormat:@"%zd", error.code]
                                    message:[error localizedDescription]];
}

//处理API数据错误，如：返回的result对象类型错误
+ (NSError *)hj_handleApiDataError {
#if DEBUG
    NSAssert(NO, @"数据类型不匹配，请检查！");
    return [self hj_errorWithDomain:HJAPIDataErrorDomain
                      codeString:[NSString stringWithFormat:@"%zd",HJSystemErrorWrongApiData]
                         message:HJSystemErrorMessageWrongApiDataMessage];;
#endif
    
    return [self hj_errorWithDomain:HJAPIDataErrorDomain
                      codeString:[NSString stringWithFormat:@"%zd",HJSystemErrorWrongApiData]
                         message:HJSystemErrorMessageWrongApiDataMessage];
}


//封装error信息到error对象，返回error
+ (NSError *)hj_errorWithDomain:(NSString *)errorDomain codeString:(NSString *)codeString message:(id)message {
    if (!message) {
        return nil;
    }
    
    NSError *aError = nil;
    
    if ([errorDomain isEqualToString:HJSystemErrorDomain]) {
        NSDictionary *userInfo = @{@"errCode" : codeString ?: @"", @"message" : message ?: @""};
        aError = [NSError errorWithDomain:HJSystemErrorDomain code:[codeString integerValue] userInfo:userInfo];
    } else if ([errorDomain isEqualToString:HJLogicErrorDomain]) {
        //将错误信息封装到error 中，抛到上层
        NSDictionary *userInfo = @{@"errCode" : codeString ?: @"", @"message" : message ?: @""};
        aError = [NSError errorWithDomain:HJLogicErrorDomain code:HJSystemErrorUnknownError userInfo:userInfo];
    }
    return aError;
}

/**
 处理token失效或者用户抢登的情况
 
 @return YES：common_0001 NO：其他code
 */
+ (BOOL)hj_handleInvalidateToken:(NSError *)error {
    
    if (![error.userInfo[@"errCode"] isEqualToString:@"common_0001"]) {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenInvalidate" object:nil userInfo:error.userInfo];
    return YES;
}

/**
 处理强制升级
 
 @return YES：common_0035 NO：其他code
 */
+ (BOOL)hj_handleForceUpdate:(NSError *)error {
    if (![error.userInfo[@"errCode"] isEqualToString:@"common_0035"]) {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"forceUpdate" object:nil userInfo:error.userInfo];
    return YES;
}

@end
