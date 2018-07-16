//
//  JKWebViewController.m
//  JiKeLoan
//
//  Created by yoser on 2018/6/12.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import "JKWebViewController.h"

#import "JKJavaSBridgeHandleMacros.h"
#import "JKJavaScriptResponse.h"
#import "JKJavaScriptGetAjaxHeaderHandler.h"


#define ResponseCallback(_value) \
!responseCallback?:responseCallback(_value);

static NSString * const kJSSetUpName = @"javascriptSetUp.js";

@interface JKWebViewController ()

@end

@implementation JKWebViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [HJJSBridgeManager new];
    [_manager setupBridge:self.wkWebView navigationDelegate:self];
    
    [self registerHander];
    [self setUpNoti];
    [self setUpUI];
    
    [_manager callHandler:kWebViewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_manager callHandler:kWebViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_manager callHandler:kWebViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_manager callHandler:kWebViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_manager callHandler:kWebViewDidDisappear];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _manager = nil;
}

#pragma mark - Private Method

- (void)setUpUI {
}

- (void)setUpNoti {
    /** 信用认证成功 */
}

- (void)registerHander {
    
    /** 注册获取请求头事件 */
    [_manager registerHandler:[JKJavaScriptGetAjaxHeaderHandler new]];
}

#pragma mark - Public Method

/** 给JS发送通用数据 */
- (void)sendMessageToJS:(id)message {
    [_manager callHandler:kJSReceiveAppData data:[JKJavaScriptResponse result:message]];
}

@end
