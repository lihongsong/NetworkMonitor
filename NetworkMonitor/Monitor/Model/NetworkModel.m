//
//  NetworkModel.m
//  NetworkMonitor
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 yoser. All rights reserved.
//

#import "NetworkModel.h"

@implementation NetworkModel

- (void)completeWithRequest:(NSURLRequest *)request {
    
    self.request = request;
    
    self.requestURLString = [request.URL absoluteString];
    
    self.requestTimeoutInterval = request.timeoutInterval;
    
    self.requestHTTPBody = [[NSString alloc] initWithData:request.HTTPBody
                                                 encoding:NSUTF8StringEncoding];
    
    self.requestAllHTTPHeaderFields = [request.allHTTPHeaderFields mutableCopy];
    
    self.requestHTTPMethod = request.HTTPMethod;
    
    self.requestCookies = [self cookiesString];
    
    self.requestCachePolicy = [self stringWithRequestCachePolicy:request.cachePolicy];
    
}

- (void)completeWithResponse:(NSHTTPURLResponse *)response {
    
    self.response = response;
    
    self.responseMIMEType = [response MIMEType] ?: @"";
    self.responseExpectedContentLength = [NSString stringWithFormat:@"%lld",[response expectedContentLength]];
    self.responseTextEncodingName = [response textEncodingName] ?: @"";
    self.responseSuggestedFilename = [response suggestedFilename] ?: @"";
    self.responseStatusCode = (int)response.statusCode;
    
    for (NSString *key in [response.allHeaderFields allKeys]) {
        NSString *headerFieldValue = [response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue=[headerFieldValue substringToIndex:11];
            }
        }
        self.responseAllHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.responseAllHeaderFields,key,headerFieldValue];
        
    }
    
    if (self.responseAllHeaderFields.length>1) {
        if ([[self.responseAllHeaderFields substringFromIndex:self.responseAllHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.responseAllHeaderFields=[self.responseAllHeaderFields substringToIndex:self.responseAllHeaderFields.length-1];
        }
    }
    
}

- (NSDictionary *)cookiesString {
    
    NSString *host = _request.URL.host;
    
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    NSMutableDictionary *cookieValueDic = [NSMutableDictionary dictionary];
    
    for (NSHTTPCookie *cookie in cookieArray) {
        
        NSString *domain = [cookie.properties valueForKey:NSHTTPCookieDomain];
        
        NSRange range = [host rangeOfString:domain];
        
        NSComparisonResult result = [cookie.expiresDate compare:[NSDate date]];
        
        if (range.location != NSNotFound && result == NSOrderedDescending) {
            [cookieValueDic setValue:cookie.value forKey:cookie.name];
        }
    }
    
    return cookieValueDic;
}

- (NSString *)stringWithRequestCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    
    NSString *cachePolicyString = @"";
    
    switch (cachePolicy) {
            
            case NSURLRequestUseProtocolCachePolicy:
            cachePolicyString = @"NSURLRequestUseProtocolCachePolicy";
            break;
            
            case NSURLRequestReloadIgnoringLocalCacheData:
            cachePolicyString = @"NSURLRequestReloadIgnoringLocalCacheData";
            break;
            
            case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            cachePolicyString = @"NSURLRequestReloadIgnoringLocalAndRemoteCacheData";
            break;
            
            case NSURLRequestReturnCacheDataElseLoad:
            cachePolicyString = @"NSURLRequestReturnCacheDataElseLoad";
            break;
            
            case NSURLRequestReturnCacheDataDontLoad:
            cachePolicyString = @"NSURLRequestReturnCacheDataDontLoad";
            break;
            
            case NSURLRequestReloadRevalidatingCacheData:
            cachePolicyString = @"NSURLRequestReloadRevalidatingCacheData";
            break;
            
        default:
            break;
    }
    return cachePolicyString;
}

@end
