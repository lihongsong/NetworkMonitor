//
//  ILBannerModel.h
//  Installmentloan
//
//  Created by Jacue on 2018/2/6.
//  Copyright © 2018年 terrywang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBannerVersionStamp @"kBannerVersionStamp"

@interface JKBannerInfo:NSObject

NS_ASSUME_NONNULL_BEGIN

/*
 
 action    支持native的页面标识    string
 imageUrl    图片url    string
 needLogin    是否需要登录    boolean
 openType    打开方式    number
 redirectUrl    重定向url    string
 */

/************************************************************************************
 "2" --- 进入邀请页  ---  "3" --- 进入我的免息卷  ---  "4" --- 进入免息页面
 "5" --- 进入提额页面  ---  "6" --- 进入银行卡页面  ---  "7" --- 进入账单列表
 "8" --- 进入首页页面  ---  "9" --- 进入我的页面  ---   "10" --- 修改手机号
 "11" --- 修改借款密码 ---  "12" --- 修改登录密码 --- "13" --- 去登录、注册
 ************************************************************************************/
@property(nonatomic,copy)NSString *action;
@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,assign)BOOL needLogin;
// 1：app内webview 2：native 3：外部浏览器
@property(nonatomic,strong)NSNumber *openType;
@property(nonatomic,copy)NSString *redirectUrl;

NS_ASSUME_NONNULL_END

@end

NS_ASSUME_NONNULL_BEGIN
@interface JKBannerModel : NSObject

@property (nonatomic, strong) NSArray<JKBannerInfo *> *bannerList;
@property (nonatomic, strong) NSNumber *versionStamp;

+ (NSURLSessionTask *)requestBannerInfoWithVersionStamp:(NSString *)versionStamp
                                             completion:(void (^)(JKBannerModel * _Nullable bannerModel,
                                                                  NSError * _Nullable error))completion;

@end
NS_ASSUME_NONNULL_END
