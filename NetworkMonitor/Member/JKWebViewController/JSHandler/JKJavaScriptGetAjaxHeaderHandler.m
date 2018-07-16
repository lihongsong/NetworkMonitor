//
//  JKJavaScriptGetAjaxHeaderHandler.m
//  JiKeLoan
//
//  Created by yoser on 2018/6/19.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import "JKJavaScriptGetAjaxHeaderHandler.h"
#import "JKJavaSBridgeHandleMacros.h"
#import "JKJavaScriptResponse.h"

@implementation JKJavaScriptGetAjaxHeaderHandler

- (NSString *)handlerName {
    return kAppGetAjaxHeader;
}

//{
//    userId = 109460034;
//    os = iOS;
//    uid = 0C9C71FC-044E-4D14-BEF6-5715A2FCE1A5;
//    channel = jkd-appstorejkj_fr_liuj;
//    manufacture = apple;
//    operators = ;
//    version = 8.1.0;
//    token = 3D4B431FCE3E0D9E7C1D8B2BE0F9C9E015535F12552E50C49D4B96E953DFFF23;
//    pid = 10002;
//}

- (void)didReceiveMessage:(id)message hander:(HJResponseCallback)hander {
    
    NSString *pid = @(10002).stringValue;
    NSString *uid = @"0C9C71FC-044E-4D14-BEF6-5715A2FCE1A5";
    NSString *channel = @"jkd-appstorejkj_fr_liuj";
    NSString *os = @"iOS";
    NSString *token = @"3D4B431FCE3E0D9E7C1D8B2BE0F9C9E015535F12552E50C49D4B96E953DFFF23";
    NSString *version = @"8.1.0";
    NSString *useid = @"109460034";
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:uid forKey:@"uid"];
    [param setValue:channel forKey:@"channel"];
    [param setValue:os forKey:@"os"];
    [param setValue:pid forKey:@"pid"];
    [param setValue:useid forKey:@"userId"];
    [param setValue:token forKey:@"token"];
    [param setValue:version forKey:@"version"];
    [param setValue:@"apple" forKey:@"manufacture"];
    [param setValue:@"" forKey:@"operators"];
    
    !hander?:hander([JKJavaScriptResponse result:param]);
}

@end
