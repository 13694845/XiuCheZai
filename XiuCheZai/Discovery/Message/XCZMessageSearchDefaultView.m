//
//  XCZMessageSearchDefaultView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/31.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSearchDefaultView.h"
#import "XCZMessageSearchDefaultBtn.h"

@interface XCZMessageSearchDefaultView()

@end

@implementation XCZMessageSearchDefaultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(48, 77, frame.size.width - 96, 1.0)];
        lineView.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0];
        [self addSubview:lineView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"可搜索的范围";
        titleLabel.font = [UIFont systemFontOfSize:18];
        CGSize titleLabelSize = [titleLabel.text boundingRectWithSize:CGSizeMake(frame.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size;
        CGFloat titleLabelW = titleLabelSize.width + 16;
        CGFloat titleLabelH = titleLabelSize.height;
        CGFloat titleLabelX = (frame.size.width - titleLabelW) * 0.5;
        CGFloat titleLabelY = lineView.frame.origin.y + lineView.bounds.size.height * 0.5 - titleLabelH * 0.5;
        titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        titleLabel.textColor = lineView.backgroundColor;
        [self addSubview:titleLabel];
        
        int count = 3;
        CGFloat searchDefaultBtnW = 80;
        CGFloat searchDefaultBtnH = 100;
        CGFloat searchDefaultBtnY = CGRectGetMaxY(titleLabel.frame) + 16;
        CGFloat marginX = (frame.size.width - count * searchDefaultBtnW) / (count + 1);
        NSArray *searchRanges = @[
                             @{
                                 @"image": @"bbs_drafts",
                                 @"title": @"文章",
                                 },
                             @{
                                 @"image": @"bbs_data",
                                 @"title": @"用户",
                                 },
                             @{
                                 @"image": @"bbs_friends_two",
                                 @"title": @"车友会",
                                 },
                             ];
        for (int i = 0; i<count; i++) {
            CGFloat searchDefaultBtnX = marginX + (marginX + searchDefaultBtnW) * i;
            XCZMessageSearchDefaultBtn *searchDefaultBtn = [[XCZMessageSearchDefaultBtn alloc] initWithFrame:CGRectMake(searchDefaultBtnX, searchDefaultBtnY, searchDefaultBtnW, searchDefaultBtnH)];
            searchDefaultBtn.dict = searchRanges[i];
            [self addSubview:searchDefaultBtn];
        }
        
    }
    return self;
}


@end
