//
//  XCZCircleDetailRemarkRowReplyView.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleDetailRemarkRowReplyView;

@protocol XCZCircleDetailRemarkRowReplyViewDelegate <NSObject>
@optional

- (void)circleDetailRemarkRowReplyView:(XCZCircleDetailRemarkRowReplyView *)circleDetailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

@end

@interface XCZCircleDetailRemarkRowReplyView : UIView

@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, strong) NSDictionary *nameDict;
@property (nonatomic, copy) NSDictionary *reply_info;
@property (nonatomic, assign) CGFloat height;

@property(nonatomic, weak) id<XCZCircleDetailRemarkRowReplyViewDelegate> delegate;

@end
