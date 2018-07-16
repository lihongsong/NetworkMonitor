//
//  JKRefreshView.h
//  AMWebBrowser
//
//  Created by AndyMu on 2017/10/30.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AMBlock)(void);

@interface JKRefreshView : UIView

@property (nonatomic, copy) AMBlock block;

@end
