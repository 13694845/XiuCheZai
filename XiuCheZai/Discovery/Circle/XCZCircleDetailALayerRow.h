//
//  XCZCircleDetailALayerRow.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleDetailALayerRow,XCZCircleDetailALayerRowReplyView;

@protocol XCZCircleDetailALayerRowDelegate <NSObject>

@optional

- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailALayerRowReplyView:(XCZCircleDetailALayerRowReplyView *)detailALayerRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;
- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews;
- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow replyViewDidClick:(UIView *)replyView;

@end

@interface XCZCircleDetailALayerRow : UIView

@property (nonatomic, assign) int type; // 0代表资讯详情传入, 1代表资讯回复楼层 某一层详细传入
@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, copy) NSString *louzhuId;
@property (nonatomic, copy) NSString *floor;
@property (nonatomic, copy) NSDictionary *remark;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) id<XCZCircleDetailALayerRowDelegate> delegate;

@end
