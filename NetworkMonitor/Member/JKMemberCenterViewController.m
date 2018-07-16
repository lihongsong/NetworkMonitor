//
//  JKMemberCenterViewController.m
//  JiKeLoan
//
//  Created by yoser on 2018/6/13.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import "JKMemberCenterViewController.h"
#import "JKWebViewController.h"

#import <Masonry/Masonry.h>

// 用户成长体系
static NSString * const kgrowthCenterUrl = @"http://t1-wsdaikuan.2345.com/xfjr/public/growthcenter/index.html";

@implementation JKUserBillIdAndBillItemIds

@end

@interface JKMemberCenterViewController ()<HJWebViewDelegate>

/** jswebview */
@property (strong, nonatomic) JKWebViewController *webViewController;

/** 是否初步加载完成 */
@property (assign, nonatomic) BOOL isLoadingFinish;

/** 是否需要刷新页面 */
@property (assign, nonatomic) BOOL isNeedUpdate;

/** 是否需要抽奖 */
@property (assign, nonatomic) BOOL isNeedlotteryDraw;

@property (strong, nonatomic) JKUserBillIdAndBillItemIds *billsModel;

@end

@implementation JKMemberCenterViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 初始化WebViewController **/
    [self setupWebViewController];
    
    /* 初始化请求 **/
    [self loadRequest];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.webViewController.delegate = nil;
}

#pragma mark - WEB的初始化

/* 初始化WebViewController **/
- (void)setupWebViewController {
    
    self.webViewController = [JKWebViewController new];
    [self addChildViewController:self.webViewController];
    [self.view addSubview:self.webViewController.view];
    self.webViewController.wkWebView.scrollView.showsVerticalScrollIndicator = NO;
    self.webViewController.delegate = self;
    [self.webViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

/* WEB重置 **/
- (void)resetWebView {
    [self.webViewController removeFromParentViewController];
    [self.webViewController.view removeFromSuperview];
    self.webViewController.delegate = nil;
    self.webViewController = nil;
}

/* 初始化请求 **/
- (void)loadRequest {

    if ([self.webViewController.wkWebView isLoading]) {
        [self.webViewController.wkWebView stopLoading];
    }
    
    _isLoadingFinish = NO;
    NSString * url = [NSString stringWithFormat:@"%@?currentTime=%.2f",kgrowthCenterUrl,CFAbsoluteTimeGetCurrent()?:0];
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webViewController loadRequest:request];
    
}



- (void)markNeedUpdate {
    _isNeedUpdate = YES;
}

@end
