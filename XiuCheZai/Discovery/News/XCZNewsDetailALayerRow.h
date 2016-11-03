//
//  XCZNewsDetailALayerRow.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewsDetailALayerRow,XCZNewsDetailALayerRowReplyView;

@protocol XCZNewsDetailALayerRowDelegate <NSObject>

@optional

- (void)detailALayerRow:(XCZNewsDetailALayerRow *)detailALayerRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailALayerRow:(XCZNewsDetailALayerRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews;
- (void)detailALayerRow:(XCZNewsDetailALayerRow *)detailALayerRow replyViewDidClick:(UIView *)replyView;
- (void)detailALayerRowReplyView:(XCZNewsDetailALayerRowReplyView *)detailALayerRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

@end

@interface XCZNewsDetailALayerRow : UIView

@property (nonatomic, assign) int type; // 0代表资讯详情传入, 1代表资讯回复楼层 某一层详细传入
@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, copy) NSString *floor;
@property (nonatomic, copy) NSDictionary *remark;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) id<XCZNewsDetailALayerRowDelegate> delegate;

@end
