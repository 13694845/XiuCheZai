//
//  XCZCircleDetailWriteView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleDetailWriteView;

@protocol XCZCircleDetailWriteViewDelegate <NSObject>

@optional
- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn;
- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text;

@end

@interface XCZCircleDetailWriteView : UIView

@property (nonatomic, weak) UITextView *commentTextView;
@property (nonatomic, weak) id<XCZCircleDetailWriteViewDelegate> delegate;


@end
