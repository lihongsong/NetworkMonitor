//
//  ILBannerModel.m
//  Installmentloan
//
//  Created by Jacue on 2018/2/6.
//  Copyright © 2018年 terrywang. All rights reserved.
//

#import "JKBannerModel.h"
#import "HJNetwork.h"
#import <YYModel/YYModel.h>

#define JK_POST_BANNER_LIST          @"/manage/banner"

@implementation JKBannerInfo

@end

@implementation JKBannerModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bannerList" : [JKBannerInfo class]
             };
}

+ (NSURLSessionTask *)requestBannerInfoWithVersionStamp:(NSString *)versionStamp
                                             completion:(void (^)(JKBannerModel * _Nullable bannerModel, NSError * _Nullable error))completion {
    
    if (versionStamp == nil) {
        versionStamp  = @"0";
    }
    
    NSDictionary *parms = @{@"versionStamp":versionStamp};
    
    return [self hj_requestModelAPI:JK_POST_BANNER_LIST
                         parameters:parms
                         completion:completion];
}

@end
