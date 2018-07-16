//
//  HJWebViewController.m
//  HJJavascriptBridgeDemo
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "HJWebViewController.h"
#import "NSBundle+HJWebView.h"

static void *HJWebContext = &HJWebContext;

@interface HJWebViewController ()

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, strong) NSURL *currentUrl;
@property (nonatomic, strong) NSURL *failUrl;
@property (nonatomic, strong) UIColor *originalTintColor;
@property (nonatomic, strong) UIColor *originalBarTintColor;

@end

@implementation HJWebViewController

#pragma mark - Static Initializers

+ (instancetype)webView {
    return [[self class] webViewWithConfiguration:nil];
}

+ (instancetype)webViewWithConfiguration:(WKWebViewConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (instancetype)initWithConfiguration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    if (self) {
        if ([WKWebView class]) {
            if (configuration) {
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            } else {
                self.wkWebView = [[WKWebView alloc] init];
            }
        }
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.wkWebView) {
        if (self.navigationController) {
            [self.wkWebView setFrame:self.view.bounds];
        } else {
            [self.wkWebView setFrame:CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        }
        [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        if (!self.wkWebView.navigationDelegate) {
            [self.wkWebView setNavigationDelegate:self];
        }
        [self.wkWebView setMultipleTouchEnabled:YES];
        [self.wkWebView setAutoresizesSubviews:YES];
        [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.wkWebView];
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:HJWebContext];
    }
    
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.originalTintColor = self.navigationController.navigationBar.tintColor;
        self.originalBarTintColor = self.navigationController.navigationBar.barTintColor;
        [self setTintColor];
        [self setBarTintColor];
        [self updateLeftBarButtonItems];
    } else {
        [self addCustomHeaderView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addProgressView];
    [self updateTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetNavigationBar];
    [self removeProgressView];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.wkWebView setNavigationDelegate:nil];
    if ([self isViewLoaded]) {
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
}

#pragma mark - Tabar State

- (void)updateTitle {
    if (self.wkWebView.loading) {
        if (self.showsURLInNavigationBar) {
            NSString *URLString;
            if (self.wkWebView) {
                URLString = [self.wkWebView.URL absoluteString];
            }
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length] - 1];
            self.navigationItem.title = URLString;
        }
    } else {
        if (self.showsPageTitleInNavigationBar) {
            if (self.wkWebView) {
                self.navigationItem.title = self.wkWebView.title;
            }
        }
    }
}

- (void)setTintColor {
    if (_tintColor) {
        [self.navigationController.navigationBar setTintColor:_tintColor];
    }
}

- (void)setBarTintColor {
    if (_barTintColor) {
        [self.navigationController.navigationBar setBarTintColor:_barTintColor];
    }
}

- (void)resetNavigationBar {
    if (_originalTintColor) {
        [self.navigationController.navigationBar setTintColor:_originalTintColor];
    }
    if (_originalBarTintColor) {
        [self.navigationController.navigationBar setBarTintColor:_originalBarTintColor];
    }
}

#pragma mark - CustomHeaderView

- (void)addCustomHeaderView {
    [self.view addSubview:self.customHeaderView];
}

- (UIView *)customHeaderView {
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _customHeaderView.backgroundColor = [UIColor whiteColor];
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"返回" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        doneButton.frame = CGRectMake(10, 20, 44, 44);
        [_customHeaderView addSubview:doneButton];
    }
    return _customHeaderView;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LeftBarButtonItems

- (void)updateLeftBarButtonItems {
    if (self.navigationItem.leftBarButtonItems.count >= 2) {
        return;
    }
    if (_wkWebView && self.wkWebView.backForwardList.backList.count >= 1) {
        if ([self checkSelfIsRootViewController]) {
            self.navigationItem.leftBarButtonItems = @[ self.backButtonItem ];
        }else {
            self.navigationItem.leftBarButtonItems = @[ self.backButtonItem, self.closeButtonItem ];
        }
    } else {
        if ([self checkSelfIsRootViewController]) {
            self.navigationItem.leftBarButtonItems = nil;
        }else {
            self.navigationItem.leftBarButtonItems = @[ self.backButtonItem ];
        }
    }
}

- (UIBarButtonItem *)backButtonItem {
    if (!_backButtonItem) {
        UIImage *backButtonItemImage =  [[UIImage imageWithContentsOfFile:[[NSBundle hj_webViewBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _backButtonItem = [[UIBarButtonItem alloc] initWithImage:backButtonItemImage landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    }
    return _backButtonItem;
}

- (UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        UIImage *closeButtonItemImage =  [[UIImage imageWithContentsOfFile:[[NSBundle hj_webViewBundle] pathForResource:@"nav_btn_close@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _closeButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonItemImage style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
        _closeButtonItem.imageInsets = UIEdgeInsetsMake(0,0,0,20);
    }
    return _closeButtonItem;
}

#pragma mark - ProgressView

- (void)addProgressView {
    if (self.navigationController) {
        [self.navigationController.navigationBar addSubview:self.progressView];
    } else {
        [self.customHeaderView addSubview:self.progressView];
    }
}

- (void)removeProgressView {
    if (self.progressView) {
        [self.progressView removeFromSuperview];
    }
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTintColor:self.navigationController.navigationBar.tintColor];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        if (self.navigationController) {
            [_progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height - _progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height)];
        } else {
            [_progressView setFrame:CGRectMake(0, self.customHeaderView.frame.size.height - _progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height)];
        }
        [_progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    }
    return _progressView;
}

#pragma mark - RefreshView

- (UIView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[UIView alloc] initWithFrame:self.view.bounds];
        _refreshView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
        [_refreshView addGestureRecognizer:tapgesture];
        
        UIImage *refreshImage =  [[UIImage imageWithContentsOfFile:[[NSBundle hj_webViewBundle] pathForResource:@"loadfail@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:refreshImage];
        imageView.center = _refreshView.center;
        [_refreshView addSubview:imageView];
        
        UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _refreshView.center.y + 36, _refreshView.frame.size.width, 50)];
        reminderLabel.text = @"页面加载失败，点击重新加载";
        reminderLabel.textColor = [UIColor grayColor];
        reminderLabel.font = [UIFont systemFontOfSize:15];
        reminderLabel.textAlignment = NSTextAlignmentCenter;
        [_refreshView addSubview:reminderLabel];
    }
    return _refreshView;
}

- (void)refresh {
    [self loadURL:_failUrl];
}

#pragma mark - Public Method

- (void)loadRequest:(NSURLRequest *)request {
    if (self.wkWebView) {
        [self.wkWebView loadRequest:request];
    }
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    [self loadURL:[NSURL URLWithString:URLString]];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    if (self.wkWebView) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
    }
}

- (void)loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl {
    if (self.wkWebView) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:baseUrl];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        self.currentUrl = webView.URL;
        [self updateTitle];
        if ([self.delegate respondsToSelector:@selector(webView:didStartLoadingURL:)]) {
            [self.delegate webView:self didStartLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        [self updateTitle];
        if (self.refreshView) {
            [self.refreshView removeFromSuperview];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingURL:)]) {
            [self.delegate webView:self didFinishLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (webView == self.wkWebView) {
        self.failUrl = _currentUrl;
        [self updateTitle];
        if (self.refreshView && error.code != NSURLErrorCancelled) {
            [self.wkWebView addSubview:self.refreshView];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (webView == self.wkWebView) {
        [self updateTitle];
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView == self.wkWebView) {
        [self updateLeftBarButtonItems];
        NSURL *URL = navigationAction.request.URL;
        if (![self externalAppRequiredToOpenURL:URL]) {
            if (!navigationAction.targetFrame) {
                [self loadURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            if ([self externalAppRequiredToFileURL:URL]) {
                [self launchExternalAppWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - UIButton Target Action Methods

- (void)closeButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonPressed:(id)sender {
    if (self.wkWebView) {
        if ([self.wkWebView canGoBack]) {
            [self.wkWebView goBack];
            if (_wkWebView && self.wkWebView.backForwardList.backList.count == 1) {
                if ([self checkSelfIsRootViewController]) {
                    self.navigationItem.leftBarButtonItems = @[];
                }
            }
        } else {
            [self closeButtonPressed:self.closeButtonItem];
        }
    }
    [self updateTitle];
}

#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0.0f animated:NO];
                             }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private Method

- (BOOL)checkSelfIsRootViewController {
    if (self.navigationController) {
        if (self.navigationController.viewControllers >0 && [self.navigationController.viewControllers indexOfObject:self] == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"http", @"https" ]];
    return ![validSchemes containsObject:URL.scheme];
}

- (BOOL)externalAppRequiredToFileURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"file" ]];
    return ![validSchemes containsObject:URL.scheme];
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:URL
                                           options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO }
                                 completionHandler:^(BOOL success){
                                 }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:URL];
#pragma clang diagnostic pop
    }
}



@end
