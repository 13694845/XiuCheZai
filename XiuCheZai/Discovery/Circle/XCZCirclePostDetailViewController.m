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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self requestNet];
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
        
//        NSLog(@)
        
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


@end
