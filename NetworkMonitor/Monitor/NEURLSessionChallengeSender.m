//
//  NEURLSessionChallengeSender.m
//  NetworkEye
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 coderyi. All rights reserved.
//

#import "NEURLSessionChallengeSender.h"

@implementation NEURLSessionChallengeSender
{
    void (^_sessionCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);
}

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    self = [super init];
    
    if(self)
    {
        _sessionCompletionHandler = [completionHandler copy];
    }
    
    return self;
}

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
}

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
}

@end
