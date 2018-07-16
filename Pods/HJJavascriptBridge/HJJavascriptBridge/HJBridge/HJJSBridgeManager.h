//
//  HJJSBridgeManager.h
//  HJJavascriptBridgeDemo
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^HJResponseCallback)(id _Nullable responseData);
typedef void (^HJDictResponseCallback)(NSDictionary * _Nullable responseData);

typedef void (^HJVoidHandler)();
typedef void (^HJDictHandler)(NSDictionary * _Nonnull data);
typedef void (^HJDictRespHandler)(NSDictionary * _Nonnull data, HJResponseCallback _Nullable responseCallback);
typedef void (^HJHandler)(id _Nonnull data, HJResponseCallback _Nullable responseCallback);

NS_ASSUME_NONNULL_BEGIN

@protocol HJBridgeProtocol <NSObject>

@required

/**
 js调用native的方法名
 */
- (NSString *)handlerName;

@optional

/**
 native接收到的JS传过来的数据
 */
- (void)didReceiveMessage:(id)message;

- (void)didReceiveMessage:(id)message hander:(HJResponseCallback)hander;

@end



@interface HJJSBridgeManager : NSObject

/**
 实例化单例
 */
+ (instancetype)shareManager;

/**
 是否输出日志
 */
+ (void)enableLogging;

/**
 初始化Bridge
 
 @param webView webView
 param navigationDelegate 需要自定义实现navigationDelegate的方法
 */
- (void)setupBridge:(WKWebView *)webView;

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id _Nullable)delegate;

#pragma mark - single

/**
 注册方法，供JS端调用
 
 @param handlerName 方法名
 @param handler 回调
 */
- (void)registerHandler:(NSString*)handlerName voidHandler:(HJVoidHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictHandler:(HJDictHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(HJDictRespHandler)handler;

- (void)registerHandler:(NSString*)handlerName handler:(HJHandler)handler;

- (void)registerHandler:(id<HJBridgeProtocol>)handler;

/**
 调用在JS端已经预埋好的方法
 
 @param handlerName 方法名
 param data 传递的数据
 param responseCallback JS接受后的回调
 */
- (void)callHandler:(NSString*)handlerName;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data responseCallback:(HJResponseCallback _Nullable)responseCallback;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data dictResponseCallback:(HJDictResponseCallback _Nullable)responseCallback;

#pragma mark - multiple

/**
 初始化遵循HJBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<HJBridgeProtocol>> *)handers;

/**
 handers的映射关系组
 */
@property (nonatomic, strong, readonly)NSMutableDictionary *dictHanders;

@end

NS_ASSUME_NONNULL_END

