//
//  XCZNewDetailRemarkSubViewRow.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewDetailRemarkRowReplyView;

@protocol XCZNewDetailRemarkRowReplyViewDelegate <NSObject>
@optional

- (void)newDetailRemarkRowReplyView:(XCZNewDetailRemarkRowReplyView *)newDetailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id;

@end

@interface XCZNewDetailRemarkRowReplyView : UIView

@property (nonatomic, assign) CGFloat fatherWidth;
@property (nonatomic, strong) NSDictionary *nameDict;
@property (nonatomic, strong) NSDictionary *reply_info;
@property (nonatomic, assign) CGFloat height;

@property(nonatomic, weak) id<XCZNewDetailRemarkRowReplyViewDelegate> delegate;

@end
