//
//  JKMemberCenterViewController.h
//  JiKeLoan
//
//  Created by yoser on 2018/6/13.
//  Copyright © 2018年 JiKeLoan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKUserBillIdAndBillItemIds : NSObject

@property (copy, nonatomic) NSString *billId;
@property (copy, nonatomic) NSArray *billItemIds;

@end

@interface JKMemberCenterViewController : UIViewController

/**
 注册通知，主要用于在viewDidLoad之前注册
 */
- (void)setupNotification;

@end



