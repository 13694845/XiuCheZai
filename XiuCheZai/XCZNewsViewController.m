//
//  XCZNewsViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsViewController.h"
#import "XCZNewsTableViewCell.h"

@interface XCZNewsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XCZNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UIImageView *v = [[UIImageView alloc] initWithImage:nil];
    v.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 110.0);
    v.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableHeaderView = v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 134.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
