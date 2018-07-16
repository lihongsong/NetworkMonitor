//
//  HJWebViewController.h
//  HJJavascriptBridgeDemo
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class HJWebViewController;

#pragma mark - HJWebViewDelegate

/**
 WKWebView的映射协议方法
 */
@protocol HJWebViewDelegate <NSObject>

@optional
/// 开始加载(a main frame navigation starts)
- (void)webView:(HJWebViewController *)webViewController didStartLoadingURL:(NSURL *)URL;
/// 加载完成(a main frame navigation completes)
- (void)webView:(HJWebViewController *)webViewController didFinishLoadingURL:(NSURL *)URL;
/// 加载失败(an error occurs while starting to load data for the main frame / an error occurs during a committed main frame navigation.)
- (void)webView:(HJWebViewController *)webViewController didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
@end

@interface HJWebViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>

#pragma mark - Initialize

/**
 实例方法初始化
 */
- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

/**
 类方法初始化
 */
+ (instancetype)webView;
+ (instancetype)webViewWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Property

@property (nonatomic, weak) id<HJWebViewDelegate> delegate;

/// UI相关
// 当前的WKWebView
@property (nonatomic, strong) WKWebView *wkWebView;

// 当前WKWebView加载失败的URL
@property (nonatomic, strong, readonly) NSURL *failUrl;

// 自定义NavigationController相关
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

// 若没有NavigationController，则可自定义customHeaderView，也可用默认设置的
@property (nonatomic, strong) UIView *customHeaderView;

// 默认的进度条添加在NavigationController上，若没有NavigationController，则加载customHeaderView上，也可以自己定义实现
@property (nonatomic, strong) UIProgressView *progressView;
// 默认的空白试图，可以自定义实现
@property (nonatomic, strong) UIView *refreshView;

@property (nonatomic, assign) BOOL showsURLInNavigationBar;
@property (nonatomic, assign) BOOL showsPageTitleInNavigationBar;


#pragma mark - Public Method

- (void)updateTitle;

- (void)loadURL:(NSURL *)URL;

- (void)loadURLString:(NSString *)URLString;

- (void)loadHTMLString:(NSString *)HTMLString;

- (void)loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl;

- (void)loadRequest:(NSURLRequest *)request;

@end
