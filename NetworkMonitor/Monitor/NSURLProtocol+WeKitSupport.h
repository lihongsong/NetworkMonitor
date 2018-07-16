//
//  NSURLProtocol+WeKitSupport.h
//  NetworkEye
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 coderyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WeKitSupport)

+ (void)wk_registerScheme:(NSString *)scheme;

+ (void)wk_unregisterScheme:(NSString *)scheme;

@end
