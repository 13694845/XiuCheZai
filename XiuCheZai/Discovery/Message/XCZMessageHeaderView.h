//
//  XCZMessageHeaderView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessageHeaderView, XCZPersonInfoHeaderOtherBtn;

@protocol XCZMessageHeaderViewDelegate <NSObject>

@optional

- (void)messageHeaderView:(XCZMessageHeaderView *)headerView signDidClick:(UILabel *)signLabel;
- (void)messageHeaderView:(XCZMessageHeaderView *)headerView otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)otherBtn;

@end

@interface XCZMessageHeaderView : UIView

@property (nonatomic, strong) NSDictionary *userDict;
@property (nonatomic, weak) id<XCZMessageHeaderViewDelegate> delegate;

@end
