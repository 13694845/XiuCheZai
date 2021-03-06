//
//  XCZMessageRecommendedViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageRecommendedViewController.h"
#import "XCZMessageRecommendedViewCell.h"
#import "XCZNewsDetailViewController.h"

@interface XCZMessageRecommendedViewController () <UITableViewDataSource, UITableViewDelegate, XCZMessageRecommendedViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;

@property (assign, nonatomic) int currentPage;

@end

@implementation XCZMessageRecommendedViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [self updateTableView]; // 暂时
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 391;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZMessageRecommendedViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.recommendedId = @"";
    cell.delegate = self;
    //    XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    // XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellB" forIndexPath:indexPath];
    // row
//    cell.row = self.rows[indexPath.row];
    return cell;
}

#pragma mark - XCZMessageRecommendedViewCellDelegate
- (void)recommendedViewCell:(XCZMessageRecommendedViewCell *)recommendedViewCell contentViewDidClick:(NSString *)recommendedId
{
    XCZNewsDetailViewController *newsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsDetailViewController"];
    // newsId
    newsDetailViewController.artid = recommendedId;
    [self.navigationController pushViewController:newsDetailViewController animated:YES];
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
