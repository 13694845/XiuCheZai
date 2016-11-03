//
//  XCZActivityViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZActivityViewController.h"
#import "XCZActivityTableViewCell.h"
#import "XCZActivityDetailViewController.h"
#import "XCZConfig.h"

@interface XCZActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (assign, nonatomic) CGFloat cellHeight;


@end

@implementation XCZActivityViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellHeight:) name:@"XCZActivityTableViewCellToVCSetupCellHeightNot" object:nil];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZActivityTableViewCellToVCSetupCellHeightNot" object:nil userInfo:@{@"cellHeight": @(cellHeight)}];
    
    [self loadData];
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

- (void)cellHeight:(NSNotification *)notification
{
    self.cellHeight = [[notification.userInfo objectForKey:@"cellHeight"] floatValue];
}

#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/QueryPostListAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"6"], @"page":[NSString stringWithFormat:@"%d", self.currentPage], @"pagesize": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                self.rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        [self endHeaderRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self endHeaderRefresh];
    }];
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.cellHeight) {
        self.cellHeight = 77.5;
    }
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    XCZActivityTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[XCZActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.cellW = self.tableView.bounds.size.width;
    cell.row = self.rows[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 跳到话题详情
    XCZActivityDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZActivityDetailViewController"];
    NSDictionary *row = self.rows[indexPath.row];
    
    NSString *identifier;
    NSString *post_clazz = row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 2) { // 投票贴，暂时没有
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
        if (imageArray.count == 1) {
            identifier = @"CellB";
        } else if (imageArray.count <= 3) {
            identifier = @"CellA1";
        } else if (imageArray.count <= 6) {
            identifier = @"CellA";
        } else {
            identifier = @"CellA2";
        }
    } else if ([post_clazz intValue] == 4) {
            identifier = @"CellC1";
    }
    circleDetailVC.post_id = row[@"post_id"];
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [imageArray addObject:[imageStrs substringToIndex:range.location]];
        [self changeImage:[imageStrs substringFromIndex:(range.location + 1)] andImageArray:imageArray];
    } else {
        [imageArray addObject:imageStrs];
    }
    return imageArray;
}

#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
    if (!self.indicatorView) {
        CGFloat indicatorViewW = 40;
        CGFloat indicatorViewH = indicatorViewW;
        CGFloat indicatorViewX = (scrollView.bounds.size.width - indicatorViewW) * 0.5;
        CGFloat indicatorViewY = - indicatorViewH;
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewH)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorView.hidden = NO;
        [scrollView addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
}

- (void)startRefresh:(UIScrollView *)scrollView
{
    [self.indicatorView startAnimating];
    [self refreshData];
}

- (void)endHeaderRefresh
{
    CGPoint offset = self.tableView.contentOffset;
    offset.y = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentOffset = offset;
        } completion:^(BOOL finished) {
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }];
    });
    
    
}

- (void)stopScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    (scrollView.contentOffset.y < -75) ? offset.y = -75 : ((scrollView.contentOffset.y > 0) ? offset.y-- : offset.y++);
    //    ((scrollView.contentOffset.y < -75) ? (offset.y = -75) : (offset.y = -75));
    [scrollView setContentOffset:offset animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self stopScroll:scrollView];
        [self startRefresh:scrollView];
    }
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        
    }
}


@end
