//
//  XCZMessageChatTabulationViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/30.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageChatTabulationViewController.h"
#import "XCZConfig.h"
#import "XCZMessageChatTabulationCell.h"

@interface XCZMessageChatTabulationViewController()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property(nonatomic, strong)NSDictionary *meInfo;
@property (assign, nonatomic) int currentPage;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZMessageChatTabulationViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"聊天";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
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
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ContactServlet.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *datas = [responseObject objectForKey:@"data"];
        NSMutableArray *rowArray = [NSMutableArray array];
        for (int i = 0; i<datas.count; i++) {
            if (i == 0) {
                self.meInfo = [datas firstObject];
            } else {
                [rowArray addObject:datas[i]];
            }
        }
        self.rows = rowArray;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZMessageChatTabulationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.row = self.rows[indexPath.row];
    return cell;
}




@end
