//
//  JKJavaScriptResponse.h
//  JiKeLoan
//
//  Created by yoser on 2018/6/19.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKJavaScriptResponse : NSObject

+ (NSString *)success;

+ (NSString *)result:(id)result;

+ (NSString *)responseCode:(NSString *)code error:(NSString *)error result:(id)result;

@end
