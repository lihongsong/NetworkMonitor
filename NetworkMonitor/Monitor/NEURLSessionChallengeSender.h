//
//  NEURLSessionChallengeSender.h
//  NetworkEye
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 coderyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEURLSessionChallengeSender : NSObject<NSURLAuthenticationChallengeSender>

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

@end
