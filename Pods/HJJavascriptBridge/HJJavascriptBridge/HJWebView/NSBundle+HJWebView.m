//
//  NSBundle+HJWebView.m
//  HJJavascriptBridge
//
//  Created by AndyMu on 2017/12/29.
//

#import "NSBundle+HJWebView.h"
#import "HJWebViewController.h"

@implementation NSBundle (HJWebView)

+ (instancetype)hj_webViewBundle {
    static NSBundle *webViewBundle = nil;
    if (webViewBundle == nil) {
        webViewBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[HJWebViewController class]] pathForResource:@"HJWebView" ofType:@"bundle"]];
    }
    return webViewBundle;
}

@end
