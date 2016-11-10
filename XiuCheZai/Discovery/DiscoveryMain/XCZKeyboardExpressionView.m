//
//  XCZKeyboardExpressionView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/4.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZKeyboardExpressionView.h"
#import "SMPageControl.h"
#import "DiscoveryConfig.h"


@implementation XCZExBtn

- (void)setExpression:(NSDictionary *)expression
{
    _expression = expression;
    
    [self setBackgroundImage:[UIImage imageNamed:expression[@"facePath"]] forState:UIControlStateNormal];
}

@end

@interface XCZKeyboardExpressionView()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *exScrollView;
@property (nonatomic, weak) SMPageControl *pageControl;

@end

@implementation XCZKeyboardExpressionView

- (void)setExpressions:(NSArray *)expressions
{
    _expressions = expressions;
    
    UIScrollView *exScrollView = [[UIScrollView alloc] init];
    exScrollView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    exScrollView.delegate = self;
    exScrollView.pagingEnabled = YES;
    exScrollView.scrollEnabled = YES;
    exScrollView.showsHorizontalScrollIndicator = NO;
    
    CGFloat screeW = [UIScreen mainScreen].bounds.size.width;
    CGFloat exScrollViewH = self.bounds.size.height; // 一页图片总高
    exScrollView.frame = CGRectMake(0, 0, screeW, exScrollViewH);
    [self addSubview:exScrollView];
    self.exScrollView = exScrollView;
    
    SMPageControl *pageControl = [[SMPageControl alloc] init];
    pageControl.indicatorMargin = 5.5;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    CGFloat pageControlH = 20;
    CGFloat pageControlY = self.bounds.size.height - pageControlH;
    pageControl.frame = CGRectMake(0, pageControlY, self.bounds.size.width, pageControlH);
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    int totalCol; // 一行的列数
    int totalRow; // 一行的行数
        totalCol = 7;
        totalRow = 3;
    int marginX = 15;
    if (kDevice_Is_iPhone6) {
        marginX = 20;
    }
    if (kDevice_Is_iPhone6Plus) {
        marginX = 25;
    }
    
    CGFloat exBtnW = (screeW - marginX)/totalCol - marginX;
    CGFloat exBtnH = exBtnW;
    CGFloat exH = self.bounds.size.height - 35; // 一页图片总高
    int marginY = exH/totalRow - exBtnH;
    
    for (int i=0; i<expressions.count; i++) {
        XCZExBtn *exBtn = [[XCZExBtn alloc] init];
        exBtn.expression = expressions[i];
        int row = i / totalCol; // 行号
        int col = i % totalCol; // 列号
        int n = row/totalRow; // 取出scrollView分页的页号
        CGFloat exBtnX = marginX + col * (marginX + exBtnW) + n * screeW;
        CGFloat exBtnY = marginY + (row - 3 * n) * (marginY + exBtnH);
        exBtn.frame = CGRectMake(exBtnX, exBtnY, exBtnW, exBtnH);
        [self.exScrollView addSubview:exBtn];
        
        pageControl.currentPage = 0;
        pageControl.numberOfPages = n+1;
        self.exScrollView.contentSize = CGSizeMake((n+1)*screeW, self.bounds.size.height);
        [exBtn addTarget:self action:@selector(exBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - scrollView的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self.pageControl.currentPage = offsetX / screenW + 0.5;
}

#pragma mark - 监听按钮的点击
- (void)exBtnDidClick:(XCZExBtn *)exBtn
{
    if ([self.delegate respondsToSelector:@selector(expressionView:exBtnDidClick:)]) {
        [self.delegate expressionView:self exBtnDidClick:exBtn];
    }
}


@end
