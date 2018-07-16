//
//  NetworkMonitor.h
//  NetworkMonitor
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 yoser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkMonitor : NSURLProtocol

/**
 *  开启 or 关闭 HTTP/HTTPS 监测
 *
 *  @param enabled 是否开启
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 *  display HTTP/HTTPS monitor state
 *
 *  @return HTTP/HTTPS monitor state
 */
+ (BOOL)isEnabled;

@end
