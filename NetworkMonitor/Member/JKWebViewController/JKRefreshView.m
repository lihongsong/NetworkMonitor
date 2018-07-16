//
//  JKRefreshView.m
//  AMWebBrowser
//
//  Created by AndyMu on 2017/10/30.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "JKRefreshView.h"

#import <Masonry/Masonry.h>

@implementation JKRefreshView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self customView];
}

- (void)customView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_loadfail"]];
    [self addSubview:imageView];
    
    UILabel *reminderLabel = [UILabel new];
    reminderLabel.text = @"页面加载失败，请重新加载或检查网络";
    reminderLabel.textColor = [UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
    reminderLabel.font = [UIFont systemFontOfSize:13];
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:reminderLabel];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:105.0f/255.0f blue:68.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:105.0f/255.0f blue:68.0f/255.0f alpha:1.0f]CGColor]];
    [button.layer setBorderWidth:0.5];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:14];
    [button addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [reminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(-49);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(reminderLabel.mas_top).offset(-25);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(72);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reminderLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(28);
    }];
}

- (void)refresh{
    if (_block) { _block();}
}

@end
