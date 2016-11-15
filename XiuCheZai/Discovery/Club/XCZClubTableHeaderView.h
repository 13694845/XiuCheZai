//
//  XCZClubTableHeaderView.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZClubTableHeaderView, XCZClubTableHeaderSubView;

@protocol XCZClubTableHeaderViewDelegate <NSObject>

@optional
- (void)clubTableHeaderView:(XCZClubTableHeaderView *)clubTableHeaderView headerSubViewDidClick:(XCZClubTableHeaderSubView *)headerSubView;

@end

@interface XCZClubTableHeaderView : UIView

@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, strong) NSArray *banners;

@property (nonatomic, weak) id<XCZClubTableHeaderViewDelegate> delegate;

@end
