//
//  XCZPublishNoOrdersView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/11.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  没有订单时
//

#import <UIKit/UIKit.h>
@class XCZPublishNoOrdersView;

@protocol XCZPublishNoOrdersViewDelegate <NSObject>

@optional
- (void)publishNoOrdersView:(XCZPublishNoOrdersView *)publishNoOrdersView goBtnDidClick:(UIButton *)goBtn;

@end

@interface XCZPublishNoOrdersView : UIView

@property (nonatomic, weak) id<XCZPublishNoOrdersViewDelegate> delegate;

@end
