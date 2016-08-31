//
//  XCZCircleViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleViewController.h"
#import "XCZCircleTableViewCell.h"

@interface XCZCircleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XCZCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 305;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZCircleTableViewCell*cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellC" forIndexPath:indexPath];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
