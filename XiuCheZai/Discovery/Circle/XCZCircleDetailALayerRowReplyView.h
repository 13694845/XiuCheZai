//
//  XCZCircleDetailALayerRowReplyView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleDetailALayerRowReplyView;

@protocol XCZCircleDetailALayerRowReplyViewDelegate <NSObject>
@optional

- (void)circleDetailALayerRowReplyView:(XCZCircleDetailALayerRowReplyView *)circleDetailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

@end

@interface XCZCircleDetailALayerRowReplyView : UIView

@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, strong) NSDictionary *nameDict;
@property (nonatomic, strong) NSDictionary *reply_info;
@property (nonatomic, assign) CGFloat height;

@property(nonatomic, weak) id<XCZCircleDetailALayerRowReplyViewDelegate> delegate;

@end
