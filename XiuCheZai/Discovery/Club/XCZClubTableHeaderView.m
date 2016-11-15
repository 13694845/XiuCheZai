//
//  XCZClubTableHeaderView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubTableHeaderView.h"
#import "XCZClubTableHeaderSubView.h"

@interface XCZClubTableHeaderView()

//@property (nonatomic, assign) CGFloat height;

@end

@implementation XCZClubTableHeaderView


- (void)setBanners:(NSArray *)banners
{
    _banners = banners;
    
    [self clearSubViews];
    [self setupSubVIews];
    
}

- (void)clearSubViews
{
    
}

- (void)setupSubVIews
{
    int i = 0;
    CGFloat margin = 16;
    CGFloat headerSubViewW = (self.tableViewWidth - margin * 3) * 0.5;
    CGFloat headerSubViewH = 42;
    for (NSDictionary *banner in self.banners) {
        XCZClubTableHeaderSubView *headerSubView = [[XCZClubTableHeaderSubView alloc] init];
        headerSubView.selfW = headerSubViewW;
        headerSubView.selfH = headerSubViewH;
        headerSubView.banner = banner;
        CGFloat liehao = i%2;
        CGFloat hanghao = i/2;
        CGFloat headerSubViewX = margin + liehao * (headerSubViewW + margin);
        CGFloat headerSubViewY = margin + hanghao * (headerSubViewH + margin);
        headerSubView.frame = CGRectMake(headerSubViewX, headerSubViewY, headerSubViewW, headerSubViewH);
        [self addSubview:headerSubView];
        [headerSubView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerSubViewDidClick:)]];
        i++;
        
        if (i == self.banners.count) {
            self.bounds = CGRectMake(0, 0, self.tableViewWidth, CGRectGetMaxY(headerSubView.frame) + margin * 0.5);
        }
    }
}

- (void)headerSubViewDidClick:(UIGestureRecognizer *)grz
{
    XCZClubTableHeaderSubView *headerSubView = (XCZClubTableHeaderSubView *)grz.view;
    if ([self.delegate respondsToSelector:@selector(clubTableHeaderView:headerSubViewDidClick:)]) {
        [self.delegate clubTableHeaderView:self headerSubViewDidClick:headerSubView];
    }
}


@end















