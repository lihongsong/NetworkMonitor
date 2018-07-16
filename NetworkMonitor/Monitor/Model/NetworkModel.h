//
//  NetworkModel.h
//  NetworkMonitor
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 yoser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModel : NSObject

#pragma mark - Request

/**
 请求
 */
@property (nonatomic, strong) NSURLRequest *request;

/**
cookies
 */
@property (nonatomic, strong) NSDictionary *requestCookies;

/**
 请求响应
 */
@property (nonatomic, strong) NSHTTPURLResponse *response;

/**
 请求 id
 */
@property (nonatomic, copy) NSString *requestId;

/**
 请求时间字符串
 */
@property (nonatomic, strong) NSString *startDateString;

/**
 请求时间字符串
 */
@property (nonatomic, strong) NSString *endDateString;

/**
 请求 URL
 */
@property (nonatomic, strong) NSString *requestURLString;

/**
 请求缓存策略
 */
@property (nonatomic, strong) NSString *requestCachePolicy;

/**
 请求超时时间
 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/**
 请求方式 [GET/POST...]
 */
@property (nonatomic, nullable, strong) NSString *requestHTTPMethod;

/**
 请求头信息
 */
@property (nonatomic, nullable, strong) NSDictionary *requestAllHTTPHeaderFields;

/**
 请求 body
 */
@property (nonatomic, nullable, strong) NSString *requestHTTPBody;

#pragma mark - Response

/**
 MIME type
 */
@property (nonatomic, nullable, strong) NSString *responseMIMEType;

/**
 内容长度
 */
@property (nonatomic, strong) NSString *responseExpectedContentLength;

/**
 内容长度
 */
@property (nonatomic, strong) NSString *responseContentLength;

/**
 响应编码
 */
@property (nonatomic, nullable, strong) NSString *responseTextEncodingName;

@property (nullable, nonatomic, strong) NSString *responseSuggestedFilename;

/**
 响应码
 */
@property (nonatomic, assign) int responseStatusCode;

/**
 响应头
 */
@property (nonatomic, nullable, strong) NSString *responseAllHeaderFields;

/**
 响应数据内容
 */
@property (nonatomic, strong) NSString *receiveJSONData;

@property (nonatomic, strong) NSString *mapPath;

@property (nonatomic, strong) NSString *mapJSONData;

- (void)completeWithRequest:(NSURLRequest *)request;

- (void)completeWithResponse:(NSHTTPURLResponse *)response;

@end
