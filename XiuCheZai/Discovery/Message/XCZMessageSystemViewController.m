//
//  XCZMessageSystemViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSystemViewController.h"
#import "XCZMessageSystemViewCell.h"
#import "XCZMessageLogisticsViewController.h"

@interface XCZMessageSystemViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;

@end

@implementation XCZMessageSystemViewController

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
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableHeaderView = self.headerView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [self.headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewDidClick)]];
    [self updateTableView]; // 暂时先这样
    [self loadData];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData {
//    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/BbsArtListAction.do"];
//    NSDictionary *parameters = nil;
//    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        self.rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
//    
    /*
     URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/banner.do"];
     parameters = nil;
     [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
     self.banner = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
     } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
     */
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 59;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZMessageSystemViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    
    //    XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    // XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellB" forIndexPath:indexPath];
    // row
//    cell.row = self.rows[indexPath.row];
    return cell;
}


- (void)headerViewDidClick
{
    XCZMessageLogisticsViewController *logisticsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageLogisticsViewController"];
    [self.navigationController pushViewController:logisticsVC animated:YES];
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
