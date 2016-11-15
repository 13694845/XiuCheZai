//
//  XCZCirclePostDetailViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/2.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCirclePostDetailViewController.h"
#import "XCZConfig.h"
#import "XCZCirclePostDetailViewCell.h"
#import "XCZPersonWebViewController.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZCirclePostDetailViewController()<UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *rows;

@end

@implementation XCZCirclePostDetailViewController

@synthesize rows = _rows;

- (void)setRows:(NSArray *)rows
{
    _rows = rows;
    [self.tableView reloadData];
}

- (NSArray *)rows
{
    if (!_rows) {
        _rows = [NSArray array];
    }
    return _rows;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"订单详情";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [self requestNet];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type": @"4", @"post_id": self.post_id, @"goods_id": self.goods_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.rows = [responseObject objectForKey:@"data"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 93;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZCirclePostDetailViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.order_good = self.rows[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (((NSString *)self.rows[indexPath.row][@"goods_id"]).length < 8) {
        [MBProgressHUD ZHMShowError:@"产品不存在"];
    } else {
        [self goProductDetails:self.rows[indexPath.row][@"goods_id"]];
    }
    
}

- (void)goProductDetails:(NSString *)goods_id
{
    NSLog(@"goods_idgoods_id:%@", goods_id);
        NSString *overUrlStrPin = [NSString stringWithFormat:@"/detail/index.html?goodsId=%@", goods_id];
        NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    
        [self launchOuterWebViewWithURLString:overUrlStr];
}

- (void)launchOuterWebViewWithURLString:(NSString *)urlString {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}


@end
