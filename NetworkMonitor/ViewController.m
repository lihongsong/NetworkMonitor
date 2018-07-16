//
//  ViewController.m
//  NetworkMonitor
//
//  Created by yoser on 2018/7/12.
//  Copyright © 2018年 yoser. All rights reserved.
//

#import "ViewController.h"
#import "NEHTTPEyeViewController.h"
#import "JKBannerModel.h"
#import "JKMemberCenterViewController.h"

#import <WebKit/WebKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kgrowthCenterUrl = @"http://t1-wsdaikuan.2345.com/xfjr/public/growthcenter/index.html";

@interface ViewController ()<NSURLSessionDataDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *reqString = @"POST /gateway/manage/banner HTTP/1.1\nHost: 172.16.0.141:10014\nUser-Agent: \nterminalId: 2\nX-Idfa: 0F858282-8D72-4DD9-9E0B-CCEDA09E839F\nX-DeviceToken: FC8A3038-B7BE-48B6-B8A7-456B2592119B\ngroupId: 2\nversion: 5.1\nos: iOS\nContent-Length: 14\nbundleId: me.ImmediatelyLoan.app\ntoken: \nConnection: keep-alive\nX-Ip: 00000000-0000-0000-0000-000000000000\nAuthorization: Basic c3VpeGluZGFpOjFxYXohQCMk\nAccept-Language: en;q=1\napp-bundle-id: \npid: 10002\nAccept: */*\nContent-Type: application/x-www-form-urlencoded\nAccept-Encoding: gzip, deflate\n\nversionStamp=0";
    
    NSData *dataRequest = [reqString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"data = %ld", dataRequest.length);
    
    NSString *responseString = @"HTTP/1.1 200\n{'result':{},'code':'success','error':{'message':''}}";
    
    NSData *dataResponse = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"data = %ld", dataResponse.length);
    
}

- (IBAction)record:(id)sender {
    
#if defined(DEBUG)||defined(_DEBUG)
    NEHTTPEyeViewController *vc = [[NEHTTPEyeViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
#endif
    
}

- (IBAction)afn:(UIButton *)sender {
    
    [JKBannerModel requestBannerInfoWithVersionStamp:nil completion:^(JKBannerModel * _Nullable bannerModel, NSError * _Nullable error) {
        
        NSLog(@"error = %@",error);
        
    }];
    
    
}

- (IBAction)session:(UIButton *)sender {
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"data = %@",data);
    }];
    
    [dataTask resume];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.imageView.image = nil;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://goss.veer.com/creative/vcg/veer/612/veer-303660154.jpg"] placeholderImage:nil options:SDWebImageRefreshCached];
}


- (IBAction)connection:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.baiduddd.com"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               NSLog(@"data = %@",data);
                               NSLog(@"error = %@",connectionError);
                           }];
}

- (IBAction)loadWebView:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:kgrowthCenterUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (IBAction)gotoWebview:(id)sender {
    JKMemberCenterViewController *vc = [JKMemberCenterViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
