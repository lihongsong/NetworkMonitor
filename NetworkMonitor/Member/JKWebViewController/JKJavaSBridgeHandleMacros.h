//
//  JKJavaSBridgeHandleMacros.h
//  JiKeLoan
//
//  Created by yoser on 2018/6/19.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#ifndef JKJavaSBridgeHandleMacros_h
#define JKJavaSBridgeHandleMacros_h

/*!
 app打开原生页面
 */
static NSString * const kAppOpenNative = @"appOpenNative";

/*!
 app埋点
 */
static NSString * const kAppExecStatistic = @"appExecStatistic";

/*!
 app页面返回
 */
static NSString * const kAppExecBack = @"appExecBack";

/*!
 获取productID
 */
static NSString * const kAppGetProductId = @"appGetProductId";

/*!
 获取信用分
 */
static NSString * const kAppGetCreditScore = @"appGetCreditScore";

/*!
 获取微信是否安装
 */
static NSString * const kAppGetWXAppInstalled = @"appGetWXAppInstalled";

/*!
 获取ChannelID
 */
static NSString * const kAppGetChannel = @"appGetChannel";

/*!
 获取app版本
 */
static NSString * const kAppGetVersion = @"appGetVersion";

/*!
 获取bundleID
 */
static NSString * const kAppGetBundleId = @"appGetBundleId";

/*!
 获取用户token
 */
static NSString * const kAppGetUserToken = @"appGetUserToken";

/*!
 获取用户唯一id
 */
static NSString * const kAppGetUserId = @"appGetUserId";

/*!
 获取手机号
 */
static NSString * const kAppGetMobilephone = @"appGetMobilephone";

/*!
 获取用户是否登录
 */
static NSString * const kAppIsLogin = @"appIsLogin";

/*!
 获取设备类型 (iOS/Android)
 */
static NSString * const kAppGetDeviceType = @"appGetDeviceType";

/*!
 获取设备唯一标识
 */
static NSString * const kAppGetDeviceUID = @"appGetDeviceUID";

/*!
 打开webView
 */
static NSString * const kAppOpenWebview = @"appOpenWebview";

/*!
 打开信用中心
 */
static NSString * const kAppOpenCreditCenter = @"appOpenCreditCenter";

/*!
 给JS发送通用数据
 */
static NSString * const kJSReceiveAppData = @"jsReceiveAppData";

/*!
 给用户成长体系发送数据
 */
static NSString * const kAppGetAjaxHeader = @"appGetAjaxHeader";

/*!
 页面加载
 */
static NSString * const kWebViewDidLoad = @"webViewDidLoad";

/*!
 页面将要显示
 */
static NSString * const kWebViewWillAppear = @"webViewWillAppear";

/*!
 页面已经显示
 */
static NSString * const kWebViewDidAppear = @"webViewDidAppear";

/*!
 页面将要消失
 */
static NSString * const kWebViewWillDisappear = @"webViewWillDisappear";

/*!
 页面已经消失
 */
static NSString * const kWebViewDidDisappear = @"webViewDidDisappear";

#endif /* JKJavaSBridgeHandleMacros_h */
