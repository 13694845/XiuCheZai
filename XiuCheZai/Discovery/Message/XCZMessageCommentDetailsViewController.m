//
//  XCZMessageCommentDetailsViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageCommentDetailsViewController.h"
#import "XCZMessageCommentDetailsRemarkRow.h"
#import "DiscoveryConfig.h"
#import "XCZNewsUserListViewController.h"

@interface XCZMessageCommentDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, assign) int m;

@end

@implementation XCZMessageCommentDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self assistedSetup]; // 辅助设置
//    [self creatSubview]; // 创建子控件
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assistedSetup
{
    self.title = @"评论详情";
    self.scrollView.alwaysBounceVertical = YES;
}

//- (void)creatSubview
//{
//    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 700)];
//    [self.scrollView addSubview:self.contentView];
//    UIView *remarkView = [[UIView alloc] init];
//    remarkView.userInteractionEnabled = YES;
//    remarkView.frame = CGRectMake(0, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width, 500);
//    [self.contentView addSubview:remarkView];
//    self.remarkView = remarkView;
//    self.newsDetailModel = [[XCZNewsDetailModel alloc] init];
//    self.m = 2;
//    if (self.newsDetailModel.newsRemarks.count) {
//        int count = (self.newsDetailModel.newsRemarks.count < self.m) ? 1 : 2;
//        for (int i = 0; i<count; i++) {
//            XCZMessageCommentDetailsRemarkRow *remarkRow = [[XCZMessageCommentDetailsRemarkRow alloc] init];
//            remarkRow.fatherWidth = remarkView.bounds.size.width;
//            remarkRow.remark = self.newsDetailModel.newsRemarks[i];
//            CGFloat remarkRowY = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
//            remarkRow.frame = CGRectMake(0, remarkRowY, remarkView.bounds.size.width, remarkRow.height);
//            self.remarkHeight += remarkRow.height;
//            [remarkView addSubview:remarkRow];
//        }
//    }
//    
//    CGRect remarkViewRect = self.remarkView.frame;
//    remarkViewRect.size.height = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
//    self.remarkView.frame = remarkViewRect;
//    self.height += self.remarkHeight + XCZNewDetailRemarkRowMarginY;
//    
//    UIButton *moreReviewsBtn = [[UIButton alloc] init];
//    moreReviewsBtn.userInteractionEnabled = YES;
//    NSString *title = self.newsDetailModel.newsRemarks.count ? (self.newsDetailModel.newsRemarks.count <= 2 ? @"没有更多评论" : @"查看更多评论") : @"还没发表评论";
//    [moreReviewsBtn setTitle:title forState:UIControlStateNormal];
//    [moreReviewsBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
//    moreReviewsBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    CGSize moreReviewsBtnTitleSize = [moreReviewsBtn.titleLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : moreReviewsBtn.titleLabel.font} context:nil].size;
//    CGFloat moreReviewsBtnW = moreReviewsBtnTitleSize.width;
//    moreReviewsBtn.frame = CGRectMake((self.contentView.bounds.size.width - moreReviewsBtnW) * 0.5, self.height + XCZNewDetailRemarkRowMarginY * 2, moreReviewsBtnTitleSize.width, moreReviewsBtnTitleSize.height);
//    self.height += (XCZNewDetailRemarkRowMarginY * 2) + moreReviewsBtnTitleSize.height;
//    [self.contentView addSubview:moreReviewsBtn];
//    [self.contentView insertSubview:moreReviewsBtn atIndex:100];
//    [self setupOutFrame];
//    moreReviewsBtn.selected = (self.newsDetailModel.newsRemarks.count > 2) ? YES : NO;
//    [moreReviewsBtn addTarget:self action:@selector(moreReviewsBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)setupOutFrame
//{
//    CGRect contentViewRect = self.contentView.frame;
//    contentViewRect.size.height = self.height + XCZNewDetailRemarkRowMarginY;
//    self.contentView.frame = contentViewRect;
//    
//    CGSize contentViewSize = self.scrollView.contentSize;
//    contentViewSize.height = self.height + XCZNewDetailRemarkRowMarginY;
//    self.scrollView.contentSize = contentViewSize;
//}
//
//- (void)moreReviewsBtnDidClick:(UIButton *)moreReviewsBtn
//{
//    CGFloat remarkHeightQ = self.remarkHeight;
//    for (int i = self.m; i<self.newsDetailModel.newsRemarks.count; i++) {
//        XCZMessageCommentDetailsRemarkRow *remarkRow = [[XCZMessageCommentDetailsRemarkRow alloc] init];
//        remarkRow.fatherWidth = self.remarkView.bounds.size.width;
//        remarkRow.remark = self.newsDetailModel.newsRemarks[i];
//        CGFloat remarkRowY = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
//        remarkRow.frame = CGRectMake(0, remarkRowY, self.remarkView.bounds.size.width, remarkRow.height);
//        self.remarkHeight += remarkRow.height;
//        [self.remarkView addSubview:remarkRow];
//        self.m++;
//    }
//    
//    CGRect remarkViewRect = self.remarkView.frame;
//    remarkViewRect.size.height = self.remarkHeight;
//    self.remarkView.frame = remarkViewRect;
//    
//    CGFloat detaRemarkHeight = self.remarkHeight - remarkHeightQ;
//    self.height += detaRemarkHeight;
//    
//    CGRect moreReviewsBtnRect = moreReviewsBtn.frame;
//    moreReviewsBtnRect.origin.y = self.height - moreReviewsBtnRect.size.height;
//    moreReviewsBtn.frame = moreReviewsBtnRect;
//    [self setupOutFrame];
//    
//    if (self.m == self.newsDetailModel.newsRemarks.count) {
//        [moreReviewsBtn setTitle:@"没有更多评论" forState:UIControlStateNormal];
//        moreReviewsBtn.userInteractionEnabled = NO;
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
