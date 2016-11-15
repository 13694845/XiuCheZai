//
//  XCZPublishOrdersViewCellBottomView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/11.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPublishOrdersViewCellBottomView;

@protocol XCZPublishOrdersViewCellBottomViewDelegate <NSObject>

@optional
- (void)cellBottomViewDidClick:(XCZPublishOrdersViewCellBottomView *)cellBottomView;

@end

@interface XCZPublishOrdersViewCellBottomView : UIView

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) int stutas;
@property (nonatomic, copy) NSString *showTitle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<XCZPublishOrdersViewCellBottomViewDelegate> delegate;

@end
