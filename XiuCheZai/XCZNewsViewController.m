//
//  XCZNewsViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsViewController.h"
#import "XCZNewsTableViewCell.h"
#import "XCZNewsDetailViewController.h"
#import "Config.h"
#import "AFNetworking.h"

@interface XCZNewsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *rows;

@property (nonatomic) NSMutableArray *newses;

@end

@implementation XCZNewsViewController


- (void)setNewses:(NSMutableArray *)newses {
    
}

- (NSMutableArray *)newses {
    return nil;
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
    
    UIImageView *v = [[UIImageView alloc] initWithImage:nil];
    v.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 110.0);
    v.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
    self.tableView.tableHeaderView = v;
    
    NSLog(@"test");
    
    [self loadData];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/BbsArtListAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 134.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    // XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellB" forIndexPath:indexPath];
    // row
    cell.row = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XCZNewsDetailViewController *newsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsDetailViewController"];
    // newsId
    newsDetailViewController.newsId = nil;
    [self.parentViewController.navigationController pushViewController:newsDetailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
