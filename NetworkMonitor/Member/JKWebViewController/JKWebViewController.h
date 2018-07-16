//
//  JKWebViewController.h
//  JiKeLoan
//
//  Created by yoser on 2018/6/12.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import "HJWebViewController.h"
#import <HJJavascriptBridge/HJJSBridgeManager.h>

@interface JKWebViewController : HJWebViewController

/**
 桥接管理器
 */
@property (strong, nonatomic) HJJSBridgeManager *manager;

/** 给JS发送通用数据 */
- (void)sendMessageToJS:(id)message;

@end
