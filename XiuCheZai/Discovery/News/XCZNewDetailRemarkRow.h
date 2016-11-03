//
//  XCZNewDetailRemarkCell.h
//  XiuCheZai
//
//  Created by QSH on 16/9/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewDetailRemarkRow, XCZNewDetailRemarkRowReplyView;

@protocol XCZNewDetailRemarkRowDelegate <NSObject>

@optional
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow detailsRemarkRowDidClick:(UIButton *)moreBtn;
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailRemarkRowReplyView:(XCZNewDetailRemarkRowReplyView *)detailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews;
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow replyViewDidClick:(UIView *)replyView;


@end

@interface XCZNewDetailRemarkRow : UIView


@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, copy) NSDictionary *remark;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) id<XCZNewDetailRemarkRowDelegate> delegate;

@end
