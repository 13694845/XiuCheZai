//
//  XCZClubViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubViewController.h"
#import "XCZClubTableViewCell.h"
#import "XCZClubCircleViewController.h"
#import "XCZClubBrandsViewController.h"
#import "XCZClubTableHeaderView.h"
#import "XCZClubTableHeaderSubView.h"
#import "XCZPersonWebViewController.h"
#import "XCZClubCircleUnsubscribeViewController.h"
#import "XCZClubCircleViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZConfig.h"

@interface XCZClubViewController () <UITableViewDataSource, UITableViewDelegate, XCZClubTableHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) XCZClubTableHeaderView *clubHeaderView;

@property (strong,nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) NSMutableArray *banners;
@property (assign, nonatomic) int currentPage;

@property (strong,nonatomic) NSArray *oneRows;
@property (strong, nonatomic) NSArray *otherRows;
@property (nonatomic, copy) NSString *selectedForum_id;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZClubViewController

@synthesize rows = _rows;
@synthesize banners = _banners;

- (NSArray *)oneRows
{
    if (!_oneRows) {
        _oneRows = @[
                     @{
                         @"cate_sp" : @"122",
                         @"clicks" : @"0",
                         @"forum_id" : @"5",
                         @"forum_name" : @"阿搜狐的回复",
                         @"forum_remark" : @"zbk啊摔到",
                         @"forum_style" : @"",
                         @"members" : @"8",
                         @"parent_id" : @"0",
                         @"totals" : @"47",
                         @"user_id" : @"",
                         },
                     @{
                         @"cate_sp" : @"",
                         @"clicks" : @"",
                         @"forum_id" : @"6",
                         @"forum_name" : @"啊是否撒地方",
                         @"forum_remark" : @"萨里德好啦好地方啊十分askjdhkasfkjhasd 阿斯 u 代购法国 iu 放丝瓜水淀粉 iu 阿道夫撒上粉底发丝的还是对方哈苏豆腐哈第三幅 i 哈收到份 iu 啊都十分 i 广东省法国大使傅 i 读法死啊 u 的高帅富 i 啊 u 感到十分的发生",
                         @"forum_style" : @"",
                         @"members" : @"5",
                         @"parent_id" : @"0",
                         @"totals" : @"13",
                         @"user_id" : @"",
                         },
                     @{
                         @"cate_sp" : @"100",
                         @"clicks" : @"0",
                         @"forum_id" : @"109",
                         @"forum_name" : @"iudf",
                         @"forum_remark" : @"阿斯顿哥哥 i",
                         @"forum_style" : @"",
                         @"members" : @"0",
                         @"parent_id" : @"0",
                         @"totals" : @"3",
                         @"user_id" : @"",
                         },
                     ];
    }
    return _oneRows;
}

- (NSArray *)otherRows
{
    if (!_otherRows) {
        _otherRows = @[
                       @{
                           @"cate_sp" : @"",
                           @"clicks" : @"",
                           @"forum_id" : @"10",
                           @"forum_name" : @"奔驰",
                           @"forum_remark" : @"",
                           @"forum_style" : @"",
                           @"members" : @"5",
                           @"parent_id" : @"0",
                           @"totals" : @"20",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"",
                           @"clicks" : @"",
                           @"forum_id" : @"106",
                           @"forum_name" : @"BBS奥迪",
                           @"forum_remark" : @"非常好",
                           @"forum_style" : @"subasu",
                           @"members" : @"0",
                           @"parent_id" : @"0",
                           @"totals" : @"1",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"98",
                           @"clicks" : @"0",
                           @"forum_id" : @"1",
                           @"forum_name" : @"i 啊上帝",
                           @"forum_remark" : @"卡蛋糕卡公司打卡时对方空间嘎的司空见惯分开很久的司法鉴定撒开飞机的风格撒娇的撒封口机哈收到反馈就是对法国公司搭风格都十分的思考方法开发包括范冰冰宝宝健康 v 方便看不见看 v 把 v 就看不看就是妇科病计算机考试 v 健康 v 步伐加快步伐",
                           @"forum_style" : @"",
                           @"members" : @"2",
                           @"parent_id" : @"0",
                           @"totals" : @"63",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"122",
                           @"clicks" : @"0",
                           @"forum_id" : @"5",
                           @"forum_name" : @"水淀粉",
                           @"forum_remark" : @"zbk",
                           @"forum_style" : @"",
                           @"members" : @"8",
                           @"parent_id" : @"0",
                           @"totals" : @"47",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"",
                           @"clicks" : @"",
                           @"forum_id" : @"6",
                           @"forum_name" : @"水淀粉色短发撒地方",
                           @"forum_remark" : @"askjdhkasfkjhasd 阿斯 u 代购法国 iu 放丝瓜水淀粉 iu 阿道夫撒上粉底发丝的还是对方哈苏豆腐哈第三幅 i 哈收到份 iu 啊都十分 i 广东省法国大使傅 i 读法死啊 u 的高帅富 i 啊 u 感到十分的发生",
                           @"forum_style" : @"",
                           @"members" : @"5",
                           @"parent_id" : @"0",
                           @"totals" : @"13",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"100",
                           @"clicks" : @"0",
                           @"forum_id" : @"109",
                           @"forum_name" : @"ask 的",
                           @"forum_remark" : @"发生对抗",
                           @"forum_style" : @"",
                           @"members" : @"0",
                           @"parent_id" : @"0",
                           @"totals" : @"3",
                           @"user_id" : @"",
                       },
                       @{
                           @"cate_sp" : @"",
                           @"clicks" : @"",
                           @"forum_id" : @"101",
                           @"forum_name" : @"阿苏法国大卡",
                           @"forum_remark" : @"",
                           @"forum_style" : @"",
                           @"members" : @"2",
                           @"parent_id" : @"0",
                           @"totals" : @"1",
                           @"user_id" : @"",
                       }
                ];
    }
    return _otherRows;
}

- (void)setBanners:(NSMutableArray *)banners {
    _banners = banners;
    
    [self endHeaderRefresh];
    [self endFooterRefresh];
    
    
    
//    _banners = nil;
    
//    if (banners.count) {
        [self updateBannerView];
//    } else {
//        
//    }
}

- (NSMutableArray *)banners {
    return _banners;
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
//    NSLog(@"rowsrows:%@", rows);
    
    self.currentPage++;
    [self endHeaderRefresh];
    [self endFooterRefresh];
    
//    if (_rows.count) {
        [self updateTableView];
//    }
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)loadData {
    [self refreshData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)refreshHeaderViewData
{
    self.currentPage = 1;
    [self clearDataHeaderViewNeedsRefresh];
    [self requestHeaderViewNet];
}

- (void)loadDataNeedsRefresh {
    self.currentPage = 1;
    [self requestHeaderViewNet];
    [self requestTableViewNet];
}

- (void)clearDataNeedsRefresh {
    
}

- (void)clearDataHeaderViewNeedsRefresh {
    self.clubHeaderView = nil;
    [self.clubHeaderView removeFromSuperview];
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)updateBannerView {
    
    if (self.banners.count) {
        [self.clubHeaderView removeFromSuperview];
        self.clubHeaderView = nil;
        
        XCZClubTableHeaderView *clubHeaderView = [[XCZClubTableHeaderView alloc] init];
        clubHeaderView.backgroundColor = [UIColor whiteColor];
        clubHeaderView.tableViewWidth = self.tableView.bounds.size.width;
        clubHeaderView.banners = self.banners;
        CGFloat clubHeaderViewH = self.banners.count ? clubHeaderView.bounds.size.height : 0.0;
        clubHeaderView.frame = CGRectMake(0, 0, clubHeaderView.bounds.size.width, clubHeaderViewH);
        self.tableView.tableHeaderView = clubHeaderView;
        self.clubHeaderView = clubHeaderView;
        clubHeaderView.delegate = self;
    } else {
        [self.clubHeaderView removeFromSuperview];
        self.clubHeaderView = nil;
        self.tableView.tableHeaderView = nil;
    }
   
}

- (void)loadingMore
{
    [self requestTableViewNet];
}


#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
//     // 测试用
//    if (self.currentPage == 1) {
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.rows = [NSMutableArray arrayWithArray:self.oneRows];
////        });
//        
//    } else {
//        self.otherRows = nil;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.rows = [[self.rows arrayByAddingObjectsFromArray:self.otherRows] mutableCopy];
//        });
//    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)requestHeaderViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":@"0"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"msgmsgmsg:%@", responseObject[@"msg"]);
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"未登录"]) {
        } else { // 已登录
            self.banners = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)requestBrandsVCNet:(NSString *)selectedForum_id andForum_name:(NSString *)selectedForum_name
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1], @"forum_id": selectedForum_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"parameters:%@, 推荐的车友会:%@", parameters, responseObject);
        NSArray *rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        rows.count ? [self jumpToClubBrandsViewController:selectedForum_id andForum_name:selectedForum_name] : [self jumpToClubCircleViewController:selectedForum_id];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZClubTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.row = self.rows[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self requestBrandsVCNet:[self.rows[indexPath.row] objectForKey:@"forum_id"] andForum_name:[self.rows[indexPath.row] objectForKey:@"forum_name"]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    sectionBackView.backgroundColor = [UIColor whiteColor];
    UILabel *gdLabel = [[UILabel alloc] init];
    gdLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    gdLabel.text = @"更多车友会";
    gdLabel.font = [UIFont systemFontOfSize:10];
    gdLabel.frame = CGRectMake(16, 0, 100, 30);
    [sectionBackView addSubview:gdLabel];
    return sectionBackView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

#pragma mark - XCZClubTableHeaderViewDelegate
- (void)clubTableHeaderView:(XCZClubTableHeaderView *)clubTableHeaderView headerSubViewDidClick:(XCZClubTableHeaderSubView *)headerSubView
{
    XCZClubCircleViewController *clubCircleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleViewController"];
    // newsId
    clubCircleViewController.hasJoin = YES;
    clubCircleViewController.forum_id = headerSubView.banner[@"forum_id"];
    [self.navigationController pushViewController:clubCircleViewController animated:YES];
}

#pragma mark - 跳转控制器
- (void)jumpToClubBrandsViewController:(NSString *)forum_id andForum_name:(NSString *)forum_name
{
    XCZClubBrandsViewController *brandsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubBrandsViewController"];
    brandsVC.forum_id = forum_id;
    brandsVC.forum_name = forum_name;
    [self.navigationController pushViewController:brandsVC animated:YES];
}

- (void)jumpToClubCircleViewController:(NSString *)forum_id
{
    XCZClubCircleViewController *circleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleViewController"];
     circleVC.hasJoin = NO;
    circleVC.forum_id = forum_id;
    [self.navigationController pushViewController:circleVC animated:YES];
}

#pragma mark - 按钮点击
- (void)clubHeaderViewDidClick
{
    
}

#pragma mark - 登录部分
- (void)logining
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/bbs/car-club/index.html"];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [XCZConfig baseURL], @"/Login/login/login.html?url=", overUrlStr]];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    XCZPersonWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonWebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
    [self removeIndicatorHeaderView];
    [self removeIndicatorFooterView];
    if (!self.indicatorHeaderView) {
        CGFloat indicatorHeaderViewW = 40;
        CGFloat indicatorHeaderViewH = indicatorHeaderViewW;
        CGFloat indicatorHeaderViewX = (scrollView.bounds.size.width - indicatorHeaderViewW) * 0.5;
        CGFloat indicatorHeaderViewY = - indicatorHeaderViewH;
        UIActivityIndicatorView *indicatorHeaderView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorHeaderViewX, indicatorHeaderViewY, indicatorHeaderViewW, indicatorHeaderViewH)];
        indicatorHeaderView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorHeaderView.hidden = NO;
        [scrollView addSubview:indicatorHeaderView];
        self.indicatorHeaderView = indicatorHeaderView;
    }
}

- (void)morePullUpRefreshControl:(UIScrollView *)scrollView
{
//    [self removeIndicatorHeaderView];
    if (!self.indicatorFooterView) {
        CGFloat indicatorFooterViewW = 40;
        CGFloat indicatorFooterViewH = indicatorFooterViewW;
        CGFloat indicatorFooterViewX = (scrollView.bounds.size.width - indicatorFooterViewW) * 0.5;
        CGFloat indicatorFooterViewY = scrollView.contentSize.height;
        UIActivityIndicatorView *indicatorFooterView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorFooterViewX, indicatorFooterViewY, indicatorFooterViewW, indicatorFooterViewH)];
        indicatorFooterView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorFooterView.hidden = NO;
        [scrollView addSubview:indicatorFooterView];
        self.indicatorFooterView = indicatorFooterView;
    }
}

- (void)startHeaderRefresh:(UIScrollView *)scrollView
{
    [self.indicatorHeaderView startAnimating];
    [self refreshData];
}

- (void)startFooterRefresh:(UIScrollView *)scrollView
{
    [self.indicatorFooterView startAnimating];
    [self loadingMore];
}

- (void)endHeaderRefresh
{
    if (self.tableView.contentOffset.y <= 0) {
        CGPoint offset = self.tableView.contentOffset;
        offset.y = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.contentOffset = offset;
            } completion:^(BOOL finished) {
                [self removeIndicatorHeaderView];
            }];
        });
    }
}

- (void)endFooterRefresh
{
    [self removeIndicatorFooterView];
}

- (void)stopHeaderScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    offset.y = -75;
    [scrollView setContentOffset:offset animated:NO];
}

- (void)stopFooterScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat dealtaH = scrollView.contentSize.height - scrollView.bounds.size.height;
    offset.y = dealtaH + 75;
    if (scrollView.contentSize.height < scrollView.bounds.size.height - 75) {
        offset.y = 0;
    }
    [scrollView setContentOffset:offset animated:YES];
}

- (void)removeIndicatorHeaderView
{
    [self.indicatorHeaderView stopAnimating];
    [self.indicatorHeaderView removeFromSuperview];
    self.indicatorHeaderView = nil;
}

- (void)removeIndicatorFooterView
{
    [self.indicatorFooterView stopAnimating];
    [self.indicatorFooterView removeFromSuperview];
    self.indicatorFooterView = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    
//    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
//        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
//        if (bottomY > 75) {
////            NSLog(@"bottomY:%f, scrollViewY:%f", bottomY, scrollView.contentOffset.y);
//            [self morePullUpRefreshControl:scrollView];
//            [self stopFooterScroll:scrollView];
//            [self startFooterRefresh:scrollView];
//        }
//    }
}

@end
