//
//  XCZMessageRecommendedViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessageRecommendedViewCell;

@protocol XCZMessageRecommendedViewCellDelegate <NSObject>

@optional
- (void)recommendedViewCell:(XCZMessageRecommendedViewCell *)recommendedViewCell contentViewDidClick:(NSString *)recommendedId;
@end

@interface XCZMessageRecommendedViewCell : UITableViewCell

@property(nonatomic, strong)NSString *recommendedId;

@property (weak, nonatomic) id <XCZMessageRecommendedViewCellDelegate> delegate;


@end
