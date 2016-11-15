//
//  XCZNewsDetailALayerRowReplyView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewsDetailALayerRowReplyView;

@protocol XCZNewsDetailALayerRowReplyViewDelegate <NSObject>
@optional

- (void)newsDetailALayerRowReplyView:(XCZNewsDetailALayerRowReplyView *)newsDetailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

@end

@interface XCZNewsDetailALayerRowReplyView : UIView

@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, strong) NSDictionary *nameDict;
@property (nonatomic, strong) NSDictionary *reply_info;
@property (nonatomic, assign) CGFloat height;

@property(nonatomic, weak) id<XCZNewsDetailALayerRowReplyViewDelegate> delegate;

@end
