//
//  XCZClubCircleBrandsViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleBrandsViewController.h"
#import "XCZClubCireBrandsTableViewCell.h"
#import "XCZConfig.h"

@interface XCZClubCircleBrandsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIButton *navCloseBtn;
@property (strong, nonatomic) UIView *maskView;

@property (nonatomic) NSMutableArray *rows;

@end

@implementation XCZClubCircleBrandsViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows
{
    _rows = rows;
    [self.tableView reloadData];
}

- (NSMutableArray *)rows
{
    if (!_rows) {
        _rows = [NSMutableArray array];
    }
    return _rows;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navCloseBtn addTarget:self action:@selector(navCloseBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.0;
    [self.view addSubview:self.maskView];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestNet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navCloseBtnDidClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 网络请求
- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ContactServlet.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"常用联系人:%@", responseObject);
        self.rows = [responseObject objectForKey:@"data"];
        //         NSLog(@"rows:%@", self.rows);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];

}


#pragma mark - tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZClubCireBrandsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    return cell;
}

#pragma mark - searchBar and textField 代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect viewRect = self.view.frame;
    viewRect.origin.y -= 64;
//    CGRect searchBarRect = searchBar.frame;
//    searchBarRect.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.navBar.frame = viewRect;
//        searchBar.frame = searchBarRect;
        searchBar.showsCancelButton = YES;
        self.maskView.alpha = 0.7;
    }];
    
}

@end




















