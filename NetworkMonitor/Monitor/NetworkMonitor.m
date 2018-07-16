//
//  NetworkMonitor.m
//  NetworkMonitor
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 yoser. All rights reserved.
//

#import "NetworkMonitor.h"

#import "NEURLSessionChallengeSender.h"
#import "NetworkModel.h"
#import "NEHTTPModelManager.h"
#import "UIWindow+NEExtension.h"
#import "NEURLSessionConfiguration.h"
#import "NEKeyboardShortcutManager.h"
#import "NEHTTPEyeViewController.h"
#import "NSURLProtocol+WeKitSupport.h"

@interface NetworkMonitor ()<NSURLSessionDataDelegate>

/**
 请求会话
 */
@property (nonatomic, strong) NSURLSession *session;

/**
 请求任务
 */
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

/**
 请求响应
 */
@property (nonatomic, strong) NSURLResponse *response;

/**
 数据流
 */
@property (nonatomic, strong) NSMutableData *data;

/**
 记录请求开始时间
 */
@property (nonatomic, strong) NSDate *startDate;

/**
 请求模型
 */
@property (nonatomic,strong) NetworkModel *networkModel;

@end

@implementation NetworkMonitor


#pragma mark - public
+ (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setDouble:enabled forKey:@"NetworkEyeEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NEURLSessionConfiguration * sessionConfiguration=[NEURLSessionConfiguration defaultConfiguration];
    
    if (enabled) {
        [NSURLProtocol wk_registerScheme:@"http"];
        [NSURLProtocol wk_registerScheme:@"https"];
        [NSURLProtocol registerClass:[NetworkMonitor class]];
        if (![sessionConfiguration isSwizzle]) {
            [sessionConfiguration load];
        }
    }else{
        [NSURLProtocol wk_unregisterScheme:@"http"];
        [NSURLProtocol wk_unregisterScheme:@"https"];
        [NSURLProtocol unregisterClass:[NetworkMonitor class]];
        if ([sessionConfiguration isSwizzle]) {
            [sessionConfiguration unload];
        }
    }
#if TARGET_OS_SIMULATOR
    [NEKeyboardShortcutManager sharedManager].enabled = enabled;
    [[NEKeyboardShortcutManager sharedManager] registerSimulatorShortcutWithKey:@"n" modifiers:UIKeyModifierCommand action:^{
        NEHTTPEyeViewController *viewController = [[NEHTTPEyeViewController alloc] init];
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController]
         presentViewController:viewController animated:YES completion:nil];
    } description:nil];
#endif
}

+ (BOOL)isEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkEyeEnable"] boolValue];
}
#pragma mark - superclass methods
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)load {
    
}

/**
 是否进入自定义的 NSURLProtocol
 
 @param request 请求
 @return 是否进入
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:@"NEHTTPEye" inRequest:request] ) {
        return NO;
    }
    return YES;
}

/**
 给 POST 请求添加上 body
 
 NSURLProtocol 拦截 NSURLSession 请求时 Body 参数会丢失，
 我们可以从 HTTPBodyStream 中取出来赋值。

 @param request 请求
 @return 已经加上 body 的请求
 */
+ (NSMutableURLRequest *)copyMutablePostRequestIncludeBody:(NSURLRequest *)request {
    
    NSMutableURLRequest *tempReq = [request mutableCopy];
    if (![[tempReq HTTPMethod] isEqualToString:@"POST"] || tempReq.HTTPBody) {
        return tempReq;
    }
    
    NSInteger maxLength = 1024;
    uint8_t d[maxLength];
    NSInputStream *stream = tempReq.HTTPBodyStream;
    NSMutableData *data = [NSMutableData new];
    
    [stream open];
    
    BOOL endOfStreamReached = NO;
    
    while (!endOfStreamReached) {
        NSInteger bytesRead = [stream read:d maxLength:maxLength];
        if (bytesRead == 0) {
            endOfStreamReached = YES;
        } else if (bytesRead == -1) {
            endOfStreamReached = YES;
        } else if (stream.streamError == nil) {
            [data appendBytes:(void *)d length:bytesRead];
        }
    }
    
    tempReq.HTTPBody = [data copy];
    [stream close];
    
    return tempReq;
}


/**
 重新设置 NSURLProtocol 信息
 
 @param request 请求
 @return 重新设置过后的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    // 对请求进行标记，避免再次进度请求
    NSMutableURLRequest *mutableReqeust =
    [self copyMutablePostRequestIncludeBody:request];
    
    [NSURLProtocol setProperty:@YES
                        forKey:@"NEHTTPEye"
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

/**
 被拦截的请求开始的地方
 */
- (void)startLoading {
    
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.session = [NSURLSession sessionWithConfiguration:conf
                                                 delegate:self
                                            delegateQueue:[[NSOperationQueue alloc] init]];
    
    self.dataTask = [self.session dataTaskWithRequest:mutableRequest];
    
    [self.dataTask resume];
    
    _networkModel = [[NetworkModel alloc] init];
    
    [_networkModel completeWithRequest:mutableRequest];
    
    _networkModel.startDateString = [self stringWithDate:[NSDate date]];
    
    NSTimeInterval requestID = [[NSDate date] timeIntervalSince1970];
    
    // 时间戳有可能重复 添加一个随机数拼接作为 id
    long randomNum = ((long)(arc4random() % 1000));
    
    _networkModel.requestId = [NSString stringWithFormat:@"%ld_%ld",(long)requestID,randomNum];
}

/**
 结束加载 URL 请求
 */
- (void)stopLoading {
    
    [self.dataTask cancel];
    
    [_networkModel completeWithResponse:(NSHTTPURLResponse *)self.response];
    
    _networkModel.endDateString = [self stringWithDate:[NSDate date]];
    
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        _networkModel.receiveJSONData = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is jsonp request
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                _networkModel.receiveJSONData = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length > 0) {
            _networkModel.receiveJSONData = xmlString;
        }
    } else if ([mimeType isEqualToString:@"text/html"] || [mimeType isEqualToString:@"application/html"]) {
        NSString *htmlString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        if (htmlString && htmlString.length > 0) {
            _networkModel.receiveJSONData = htmlString;
        }
    }
    
    NSInteger contentLength = self.data.length;
    
    _networkModel.responseContentLength = [NSString stringWithFormat:@"%ld",contentLength];
    
    double flowCount =
    [[[NSUserDefaults standardUserDefaults] objectForKey:@"flowCount"] doubleValue];
    
    if (!flowCount) {
        flowCount = 0.0;
    }
    
    flowCount=flowCount+self.response.expectedContentLength / (1024.0*1024.0);
    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:@"flowCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];//https://github.com/coderyi/NetworkEye/pull/6
    [[NEHTTPModelManager defaultManager] addModel:_networkModel];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSURLAuthenticationChallenge* challengeWrapper = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:[[NEURLSessionChallengeSender alloc] initWithSessionCompletionHandler:completionHandler]];
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challengeWrapper];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task  didCompleteWithError:(NSError *)error {
    
    if (error) {
        [[self client] URLProtocol:self didFailWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        NSArray *allMapRequests = [[NEHTTPModelManager defaultManager] allMapObjects];
        for (NSInteger i=0; i < allMapRequests.count; i++) {
            NetworkModel *req = [allMapRequests objectAtIndex:i];
            if ([[_networkModel.request.URL absoluteString] containsString:req.mapPath]) {
                NSData *jsonData = [req.mapJSONData dataUsingEncoding:NSUTF8StringEncoding];
                [[self client] URLProtocol:self didLoadData:jsonData];
                [self.data appendData:jsonData];
                return;
            }
        }
    }
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        //https://github.com/coderyi/NetworkEye/issues/3
        return nil;
    }
    //https://github.com/coderyi/NetworkEye/issues/1
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[NetworkMonitor defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];//zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    });
    return staticDateFormatter;
}

@end
