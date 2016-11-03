//
//  XCZMessageTopicDetailsViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageTopicDetailsViewController.h"
#import "XCZMessageTopicDetailsRemarkRow.h"
#import "DiscoveryConfig.h"
#import "Config.h"
#import "XCZNewsUserListViewController.h"

@interface XCZMessageTopicDetailsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, assign) int m;
@property (nonatomic, weak) XCZMessageTopicDetailsRemarkRow *previousRemarkRow;


@end

@implementation XCZMessageTopicDetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self assistedSetup]; // 辅助设置
    [self creatSubview]; // 创建子控件
    // Do any additional setup after loading the view.
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
    self.scrollView.userInteractionEnabled = YES;
    self.title = @"话题详情";
}

- (void)creatSubview
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 700)];
    
    UIView *circleDetailsView = [[UIView alloc] init];
    circleDetailsView.backgroundColor = [UIColor whiteColor];
    circleDetailsView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, 58);
    [self.contentView addSubview:circleDetailsView];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    iconImageView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, XCZNewDetailRemarkRowMarginY, 42, 42);
    iconImageView.layer.cornerRadius = iconImageView.bounds.size.height * 0.5;
    [circleDetailsView addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"zhenghaimin";
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor colorWithRed:11/255.0 green:11/255.0 blue:11/255.0 alpha:1.0];
    CGSize nameLabelSize = [nameLabel.text boundingRectWithSize:CGSizeMake(circleDetailsView.bounds.size.width - 42 - 16 - 30, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : nameLabel.font} context:nil].size;
    nameLabel.frame = CGRectMake(16 + 42, 8, nameLabelSize.width, nameLabelSize.height);
    [circleDetailsView addSubview:nameLabel];
    
    UIImageView *carLoagaoImageView = [[UIImageView alloc] init];
    carLoagaoImageView.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    carLoagaoImageView.frame = CGRectMake(16 + 42 + nameLabelSize.width, 8, nameLabelSize.height, nameLabelSize.height);
    [circleDetailsView addSubview:carLoagaoImageView];
    
    UILabel *siteCircleLabel = [[UILabel alloc] init];
    siteCircleLabel.text = @"奥迪r8 椒江";
    siteCircleLabel.font = [UIFont systemFontOfSize:10];
    siteCircleLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    CGSize siteCircleLabelSize = [siteCircleLabel.text boundingRectWithSize:CGSizeMake(circleDetailsView.bounds.size.width - 42 - 16 - 30, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : siteCircleLabel.font} context:nil].size;
    siteCircleLabel.frame = CGRectMake(16 + 42, 33, siteCircleLabelSize.width, siteCircleLabelSize.height);
    [circleDetailsView addSubview:siteCircleLabel];
    
    //    UILabel *circleTitleLabel = [[UILabel alloc] init];
    //    circleTitleLabel.numberOfLines = 0;
    //    circleTitleLabel.font = [UIFont systemFontOfSize:18];
    //    circleTitleLabel.textColor = kXCTITLECOLOR;
    //    [self.contentView addSubview:circleTitleLabel];
    //
    //    UILabel *publishDateLabel = [[UILabel alloc] init];
    //    publishDateLabel.numberOfLines = 1;
    //    publishDateLabel.font = [UIFont systemFontOfSize:10];
    //    publishDateLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    //    [self.contentView addSubview:publishDateLabel];
    //
    //    UILabel *reprintFromLabel = [[UILabel alloc] init];
    //    reprintFromLabel.numberOfLines = 1;
    //    reprintFromLabel.font = [UIFont systemFontOfSize:10];
    //    reprintFromLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    //    [self.contentView addSubview:reprintFromLabel];
    
    UIWebView *newsTitleView = [[UIWebView alloc] init];
    newsTitleView.delegate = self;
    newsTitleView.scalesPageToFit = YES;
    [self.contentView addSubview:newsTitleView];
    
    UILabel *admiredView = [[UILabel alloc] init];
    [self.contentView addSubview:admiredView];
    UILabel *newsRemarksView = [[UILabel alloc] init];
    [self.contentView addSubview:newsRemarksView];
    
//    self.newsDetailModel = [[XCZNewsDetailModel alloc] init];
    //    circleTitleLabel.text = self.newsDetailModel.newsTitle;
    //    publishDateLabel.text = [NSString stringWithFormat:@"%@", self.newsDetailModel.publishDate];
    //    reprintFromLabel.text = [NSString stringWithFormat:@"%@", self.newsDetailModel.reprintFrom];
//    [newsTitleView loadHTMLString:self.newsDetailModel.newsText baseURL:nil];
    
    self.height += circleDetailsView.bounds.size.height;
    //    CGSize circleTitleViewSize = [circleTitleLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : circleTitleLabel.font} context:nil].size;
    //    circleTitleLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, circleTitleViewSize.width, circleTitleViewSize.height);
    //    self.height += circleTitleLabel.bounds.size.height + XCZNewDetailRemarkRowMarginY;
    //
    //    CGSize publishDateLabelSize = [publishDateLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX) * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : publishDateLabel.font} context:nil].size;
    //    publishDateLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, publishDateLabelSize.width, publishDateLabelSize.height);
    //
    //    CGSize reprintFromLabelSize = [reprintFromLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX) * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : reprintFromLabel.font} context:nil].size;
    //    reprintFromLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2 + CGRectGetMaxX(publishDateLabel.frame), self.height + XCZNewDetailRemarkRowMarginY, reprintFromLabelSize.width, reprintFromLabelSize.height);
    //    self.height += publishDateLabelSize.height + XCZNewDetailRemarkRowMarginY;
    
    newsTitleView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, 1);
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height =1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    self.height += fittingSize.height + XCZNewDetailRemarkRowMarginY;
    [self setupSurplusView];
}

- (void)setupSurplusView
{
    UILabel *newsTitleRemarkLabel = [[UILabel alloc] init];
    newsTitleRemarkLabel.text = @"昨天14:36";
    newsTitleRemarkLabel.font = [UIFont systemFontOfSize:10];
    newsTitleRemarkLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    CGSize newsTitleRemarkLabelSize = [newsTitleRemarkLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : newsTitleRemarkLabel.font} context:nil].size;
    newsTitleRemarkLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, newsTitleRemarkLabelSize.height);
    [self.contentView addSubview:newsTitleRemarkLabel];
    
    UIButton *delectedselfBtn = [[UIButton alloc] init];
    delectedselfBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [delectedselfBtn setTitle:@"删除本帖" forState:UIControlStateNormal];
    [delectedselfBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:82/255.0 blue:172/255.0 alpha:1.0] forState:UIControlStateNormal];
    CGSize delectedselfBtnSize = [delectedselfBtn.titleLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width * 0.5, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : delectedselfBtn.titleLabel.font} context:nil].size;
    CGFloat delectedselfBtnX = self.view.bounds.size.width - XCZNewDetailRemarkRowMarginX - delectedselfBtnSize.width;
    CGFloat delectedselfBtnY = self.height + XCZNewDetailRemarkRowMarginY;
    delectedselfBtn.frame = CGRectMake(delectedselfBtnX, delectedselfBtnY, delectedselfBtnSize.width, delectedselfBtnSize.height);
    self.height += newsTitleRemarkLabelSize.height + XCZNewDetailRemarkRowMarginY;
    [self.contentView addSubview:delectedselfBtn];
    
    UITableViewCell *admiredPersonsView = [[UITableViewCell alloc] init];
    admiredPersonsView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 50);
    admiredPersonsView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    admiredPersonsView.layer.cornerRadius = 5.0;
    admiredPersonsView.backgroundColor = [UIColor whiteColor];
    self.height += admiredPersonsView.bounds.size.height + XCZNewDetailRemarkRowMarginY;
    [self.contentView addSubview:admiredPersonsView];
    
    int admiredPersonsCount = 6;
    CGFloat admiredPersonsIconViewW = 33;
    CGFloat admiredPersonsIconViewH = admiredPersonsIconViewW;
    CGFloat admiredPersonsIconViewY = (admiredPersonsView.bounds.size.height - admiredPersonsIconViewW) * 0.5;
    for (int i = 0; i<admiredPersonsCount; i++) {
        UIImageView *admiredPersonsIconView = [[UIImageView alloc] init];
        admiredPersonsIconView.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
        CGFloat admiredPersonsIconViewX = XCZNewDetailRemarkRowMarginX + (admiredPersonsIconViewW + XCZNewDetailRemarkRowMarginX) * i;
        admiredPersonsIconView.frame = CGRectMake(admiredPersonsIconViewX, admiredPersonsIconViewY, admiredPersonsIconViewW, admiredPersonsIconViewH);
        admiredPersonsIconView.layer.cornerRadius = admiredPersonsIconViewH * 0.5;
        [admiredPersonsView addSubview:admiredPersonsIconView];
    }
    
    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.text = [NSString stringWithFormat:@"%@人点赞", @"3567"];
    numberLabel.font = [UIFont systemFontOfSize:10];
    numberLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    numberLabel.textAlignment = NSTextAlignmentRight;
    CGFloat numberLabelX = XCZNewDetailRemarkRowMarginX + (admiredPersonsIconViewW + XCZNewDetailRemarkRowMarginX) * admiredPersonsCount;
    CGFloat numberLabelW = admiredPersonsView.bounds.size.width - 23 - numberLabelX;
    CGSize numberLabelSize = [numberLabel.text boundingRectWithSize:CGSizeMake(numberLabelW, 33) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : numberLabel.font} context:nil].size;
    CGFloat numberLabelH = numberLabelSize.height;
    CGFloat numberLabelY = (admiredPersonsView.bounds.size.height - numberLabelH) * 0.5;
    numberLabel.frame = CGRectMake(numberLabelX, numberLabelY, numberLabelW, numberLabelH);
    [admiredPersonsView addSubview:numberLabel];
    
    UIView *remarkView = [[UIView alloc] init];
    remarkView.userInteractionEnabled = YES;
    remarkView.frame = CGRectMake(0, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width, 500);
    [self.contentView addSubview:remarkView];
    self.remarkView = remarkView;
    
    UILabel *commentsLabel = [[UILabel alloc] init];
    commentsLabel.text = @"评论";
    commentsLabel.font = [UIFont systemFontOfSize:16];
    commentsLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    CGSize commentsLabelSize = [commentsLabel.text boundingRectWithSize:CGSizeMake(remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : commentsLabel.font} context:nil].size;
    commentsLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, 0, remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, commentsLabelSize.height);
    self.remarkHeight = commentsLabelSize.height;
    [remarkView addSubview:commentsLabel];
    
    UILabel *commentsBeforeLabel = [[UILabel alloc] init];
    commentsBeforeLabel.text = @"载入之前的评论";
    commentsBeforeLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    commentsBeforeLabel.textAlignment = NSTextAlignmentRight;
    commentsBeforeLabel.font = [UIFont systemFontOfSize:12];
    CGFloat commentsBeforeLabelW = 100;
    CGFloat commentsBeforeLabelH = commentsLabelSize.height;
    CGFloat commentsBeforeLabelX = remarkView.bounds.size.width - commentsBeforeLabelW - XCZNewDetailRemarkRowMarginX;
    CGFloat commentsBeforeLabelY = 0;
    commentsBeforeLabel.frame = CGRectMake(commentsBeforeLabelX, commentsBeforeLabelY, commentsBeforeLabelW, commentsBeforeLabelH);
    [remarkView addSubview:commentsBeforeLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginX, commentsLabelSize.height + XCZNewDetailRemarkRowMarginY, remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 1.0)];
    lineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
    self.remarkHeight += lineView.bounds.size.height;
    [remarkView addSubview:lineView];
    
//    self.m = 2;
//    if (self.newsDetailModel.newsRemarks.count) {
//        int count = (self.newsDetailModel.newsRemarks.count < self.m) ? 1 : 2;
//        for (int i = 0; i<count; i++) {
//            XCZMessageTopicDetailsRemarkRow *remarkRow = [[XCZMessageTopicDetailsRemarkRow alloc] init];
//            remarkRow.fatherWidth = remarkView.bounds.size.width;
//            remarkRow.remark = self.newsDetailModel.newsRemarks[i];
//            CGFloat remarkRowY = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
//            remarkRow.frame = CGRectMake(0, remarkRowY, remarkView.bounds.size.width, remarkRow.height);
//            self.remarkHeight += remarkRow.height;
//            [remarkView addSubview:remarkRow];
//        }
//    }
    
    CGRect remarkViewRect = self.remarkView.frame;
    remarkViewRect.size.height = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    self.remarkView.frame = remarkViewRect;
    self.height += self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    
    UIButton *moreReviewsBtn = [[UIButton alloc] init];
    moreReviewsBtn.userInteractionEnabled = YES;
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
//    [admiredPersonsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(admiredPersonsViewDidClick)]];
}

//- (void)moreReviewsBtnDidClick:(UIButton *)moreReviewsBtn
//{
//    CGFloat remarkHeightQ = self.remarkHeight;
//    for (int i = self.m; i<self.newsDetailModel.newsRemarks.count; i++) {
//        XCZMessageTopicDetailsRemarkRow *remarkRow = [[XCZMessageTopicDetailsRemarkRow alloc] init];
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

- (void)setupOutFrame
{
    CGRect contentViewRect = self.contentView.frame;
    contentViewRect.size.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.contentView.frame = contentViewRect;
    
    CGSize contentViewSize = self.scrollView.contentSize;
    contentViewSize.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.scrollView.contentSize = contentViewSize;
}

#pragma mark - 跳转控制器
- (void)admiredPersonsViewDidClick
{
    XCZNewsUserListViewController *newsUserListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsUserListViewController"];
    [self.navigationController pushViewController:newsUserListVC animated:YES];
}
@end
