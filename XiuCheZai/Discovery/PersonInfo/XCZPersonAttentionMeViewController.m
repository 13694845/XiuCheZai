//
//  XCZAttentionMeViewController.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonAttentionMeViewController.h"
#import "XCZConfig.h"
#import "XCZPersonAttentionMeViewCell.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZPersonAttentionMeViewController () <UITableViewDataSource, UITableViewDelegate, XCZPersonAttentionMeViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZPersonAttentionMeViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
//    self.oneArray = nil;
//    _rows = [NSMutableArray arrayWithArray:self.oneArray];
    
    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关注TA的";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键关注" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemDidClick)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self loadData];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)loadData {
    [self refreshData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)loadDataNeedsRefresh {
    self.currentPage = 1;
    [self requestTableViewNet];
}

- (void)clearDataNeedsRefresh {
    
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)loadingMore
{
    [self requestTableViewNet];
}


#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSString *bbs_user_id;
    if (!self.bbs_user_id) {
#warning 如果bbs_user_id没值则取登录id
    } else {
        bbs_user_id = self.bbs_user_id;
    }

    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 4],
                                 @"bbs_user_id": self.bbs_user_id,
                                 @"page":[NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rowsz = [responseObject objectForKey:@"data"];
        NSArray *rows = [NSArray array];
        for (NSDictionary *dataDict in rowsz) {
            if ([dataDict[@"taskId"] intValue] == 4598) {
                rows = dataDict[@"rows"];
            }
        }
        if (self.currentPage == 1) {
            self.rows = [NSMutableArray arrayWithArray:rows];
        } else {
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
//                NSLog(@"rows:%@", self.rows);
        [self endHeaderRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
    }];
}

/**
 *  是否关注接口
 */
- (void)requestAttionServlet:(int)attion andUser_id:(NSString *)user_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/AttionServlet.do"];
    NSDictionary *parameters = @{@"attion":[NSString stringWithFormat:@"%d", attion], @"receiver_id": user_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"responseObject:%@", responseObject);
        [MBProgressHUD ZHMHideHUD];
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"成功"]) {
            NSLog(@"来到了阿斯顿会");
            NSString *show = (attion == 1) ? @"添加关注成功": @"取消关注成功";
            [MBProgressHUD ZHMShowSuccess:show];
            [self refreshData];
        } else {
            [MBProgressHUD ZHMShowSuccess:@"失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD ZHMHideHUD];
        [MBProgressHUD ZHMShowSuccess:@"失败"];
        //        [self endHeaderRefresh];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZPersonAttentionMeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.row = self.rows[indexPath.row];
    cell.delegate = self;
    return cell;
}
#pragma mark - XCZPersonAttentionMeViewCellDelegate
- (void)personAttentionMeViewCell:(XCZPersonAttentionMeViewCell *)personAttentionMeViewCell siteCircleLabelDidClick:(int)clazz
{
    if (!clazz) {
        [self requestAttionServlet:1 andUser_id:personAttentionMeViewCell.row[@"user_id"]]; // 去关注
    } else {
        [self requestAttionServlet:0 andUser_id:personAttentionMeViewCell.row[@"user_id"]]; // 去取消关注
    }
}


#pragma mark - 监听按钮被点击
- (void)rightBarButtonItemDidClick
{
    NSMutableString *user_id;
    NSMutableArray *clazzs = [NSMutableArray array]; // 未关注的cell
    for (NSDictionary *row in self.rows) {
        if (![row[@"clazz"] intValue]) {
           [clazzs addObject:row[@"clazz"]];
            if (user_id) {
                user_id = [NSMutableString stringWithFormat:@"%@,%@",  user_id, row[@"user_id"]];
            } else {
                user_id = [NSMutableString stringWithFormat:@"%@", row[@"user_id"]];
            }
        }
    }
    if (clazzs.count) {
        [self requestAttionServlet:1 andUser_id:user_id];
    }
}

#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
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
    [self removeIndicatorHeaderView];
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
    [scrollView setContentOffset:offset animated:YES];
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
    
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
        if (bottomY > 75) {
            [self morePullUpRefreshControl:scrollView];
            [self stopFooterScroll:scrollView];
            [self startFooterRefresh:scrollView];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
