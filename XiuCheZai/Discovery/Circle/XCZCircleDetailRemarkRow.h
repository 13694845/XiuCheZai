//
//  XCZCircleDetailRemarkRow.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleDetailRemarkRow, XCZCircleDetailRemarkRowReplyView;

@protocol XCZCircleDetailRemarkRowDelegate <NSObject>

@optional
- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow detailsRemarkRowDidClick:(UIButton *)moreBtn;
- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailRemarkRowReplyView:(XCZCircleDetailRemarkRowReplyView *)detailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow likeViewDidClick:(NSDictionary *)likeViewSubViews;
- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow replyViewDidClick:(UIView *)replyView;

@end

@interface XCZCircleDetailRemarkRow : UIView

@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, copy) NSDictionary *remark;
@property (nonatomic, copy) NSString *louzhuId;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) id<XCZCircleDetailRemarkRowDelegate> delegate;

@end
