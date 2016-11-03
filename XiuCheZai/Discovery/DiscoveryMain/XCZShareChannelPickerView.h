//
//  XCZShareChannelPickerView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface XCZShareChannelIconView : UIView

@property (nonatomic, assign) CGFloat selfW;
@property (nonatomic, strong) NSDictionary *shareRow;

@end


@class XCZShareChannelPickerView, XCZShareChannelIconView;

@protocol XCZShareChannelPickerViewDelegate <NSObject>

@optional
- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView cancelBtnDidClick:(UIButton *)cancelBtn;
- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView iconViewDidClick:(XCZShareChannelIconView *)iconView;
@end


@interface XCZShareChannelPickerView : UIView

@property (nonatomic, assign) CGFloat selfW;
@property (nonatomic, strong) NSArray *shareRows;

@property (nonatomic, weak) id<XCZShareChannelPickerViewDelegate> delegate;

@end
