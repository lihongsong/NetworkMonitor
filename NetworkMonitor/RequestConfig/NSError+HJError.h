//
//  NSError+HJError.h
//  HJNetwork
//
//  Created by terrywang on 2017/6/27.
//  Copyright © 2017年 terrywang. All rights reserved.
//

#import <Foundation/Foundation.h>
//错误定义
#define HJSystemErrorDomain   @"loan.system.error.domain"
#define HJAPIDataErrorDomain  @"loan.apidata.error.domain"
#define HJLogicErrorDomain    @"loan.logic.error.domain"

#define HJSystemErrorMessageWrongApiDataMessage  @"数据格式错误"
#define HJSystemErrorMessageUnkownErrorMessage   @"网络异常，请稍后再试"
#define HJSystemErrorMessageNetworkIssueMessage  @"网络未连接，请检查网络设置"

#define KNotificationCommon_0001       @"KNotificationCommon_0001"//用户token失效
#define KNotificationForceUserUpdate   @"KNotificationForceUserUpdate"//借还款强制更新用户信息
#define KNotificationUserYueJiSuccess  @"KNotificationUserYueJiSuccess"//用户月结成功,但是WS返回系统异常,通知还款页面

static NSString *const kTokenInvalidateCode = @"common_0001";
static NSString *const kForceUpdateCode     = @"common_0035";
static NSString *const kAnquanxinxiCode     = @"anquanxinxi_0034";

//错误类别
typedef enum
{
    HJSystemErrorWrongApiData = 1,
    HJSystemErrorNetworkIssue,
    HJSystemErrorUnknownError
    
} HJErrorStatus;

@interface NSError (HJError)

/**
 封装错误信息并返回
 
 @return 返回封装后的具体错误信息
 */
- (NSString *)hj_errorMessage;

/**
 处理系统异常，例如服务器异常
 
 @param error 原始error
 @return 返回重新封装的error
 */
+ (NSError *)hj_handleSystemError:(NSError *)error;

/**
 处理业务异常，例如登录异常
 
 @param error 原始error
 @return 返回重新封装的error
 */
+ (NSError *)hj_handleLogicError:(NSDictionary *)error;

+ (NSError *)hj_handleApiDataError;

@end
