//
//  HJJSBridgeManager.m
//  HJJavascriptBridgeDemo
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "HJJSBridgeManager.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@interface HJJSBridgeManager ()

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, copy) NSArray<id<HJBridgeProtocol>> * handers;
@property (nonatomic, strong)NSMutableDictionary *dictHanders;

@end

@implementation HJJSBridgeManager

#pragma mark -

/**
 实例化单例
 */
+ (instancetype)shareManager {
    static HJJSBridgeManager *jsBridgeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsBridgeManager = [[[self class] alloc] init];
    });
    return jsBridgeManager;
}

+ (void)enableLogging {
    [WKWebViewJavascriptBridge enableLogging];
}

#pragma mark - setup

- (void)setupBridge:(WKWebView *)webView {
    [self setupBridge:webView navigationDelegate:nil];
}

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id)delegate {
    
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    if (delegate) {
        [_bridge setWebViewDelegate:delegate];
    }
}

#pragma mark - register

- (void)registerHandler:(NSString*)handlerName voidHandler:(HJVoidHandler)handler {
    
    [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        if (handler) { handler();}
    }];
}

- (void)registerHandler:(NSString*)handlerName dictHandler:(HJDictHandler)handler {
    
    [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            handler((NSDictionary *)data);
        }
    }];
}

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(HJDictRespHandler)handler {
    
    [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            handler((NSDictionary *)data, responseCallback);
        }
    }];
}

- (void)registerHandler:(NSString *)handlerName handler:(HJHandler)handler {
    [_bridge registerHandler:handlerName handler:handler];
}

- (void)registerHandler:(id<HJBridgeProtocol>)handler {
    
    NSString *handlerName = [handler handlerName];
    
    [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        
        if ([handler respondsToSelector:@selector(didReceiveMessage:hander:)]) {
            [handler didReceiveMessage:data hander:responseCallback];
        }
        if ([handler respondsToSelector:@selector(didReceiveMessage:)]) {
            [handler didReceiveMessage:data];
        }
    }];
}

#pragma mark - call

- (void)callHandler:(NSString*)handlerName {
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString*)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(HJResponseCallback)responseCallback {
    [_bridge callHandler:handlerName data:data responseCallback:responseCallback];
}

- (void)callHandler:(NSString*)handlerName data:(id)data dictResponseCallback:(HJDictResponseCallback)responseCallback {
    [_bridge callHandler:handlerName data:data responseCallback:^(id responseData) {
        if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
            responseCallback((NSDictionary *)responseData);
        }
    }];
}

#pragma mark - multiple

/**
 初始化遵循HJBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<HJBridgeProtocol>> *)handers {
    for (id<HJBridgeProtocol> hander in handers) {
        [self addHander:hander];
    }
}

- (void)addHander:(id<HJBridgeProtocol>)hander {
    NSString *handerName = nil;
    if ([hander respondsToSelector:@selector(handlerName)]) {
        handerName = [hander handlerName];
    }
    if (!handerName || [_dictHanders objectForKey:handerName]) { return; }
    [_dictHanders setValue:hander forKey:handerName];
    [self registerHandler:handerName handler:^(id  _Nonnull data, HJResponseCallback  _Nullable responseCallback) {
        if ([hander respondsToSelector:@selector(didReceiveMessage:hander:)]) {
            [hander didReceiveMessage:data hander:responseCallback];
        }
        if ([hander respondsToSelector:@selector(didReceiveMessage:)] && [data isKindOfClass:[NSDictionary class]]) {
            [hander didReceiveMessage:(NSDictionary *)data];
        }
    }];
}

@end
