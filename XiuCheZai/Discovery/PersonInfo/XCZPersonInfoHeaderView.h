//
//  XCZPersonInfoHeaderView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPersonInfoHeaderView, XCZPersonInfoHeaderOtherBtn;

@protocol XCZPersonInfoHeaderViewDelegate <NSObject>

@optional
- (void)personInfoHeaderView:(XCZPersonInfoHeaderView *)headerView otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)otherBtn;

@end

@interface XCZPersonInfoHeaderView : UIView

@property (nonatomic, strong) NSDictionary *banner;
@property (nonatomic, assign) CGFloat selfW;
@property (nonatomic, weak) id<XCZPersonInfoHeaderViewDelegate> delegate;

@end
