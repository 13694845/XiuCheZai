//
//  BrandSelectorViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "BrandSelectorViewController.h"
#import "BrandSelectorCell.h"

@interface BrandSelectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *brands;

@end

@implementation BrandSelectorViewController

- (NSMutableArray *)brands {
    if (!_brands) _brands = [NSMutableArray array];
    return _brands;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadData];
}

- (void)loadData {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BrandSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.brandImageView.image = [UIImage imageNamed:@"bmw.jpg"];
    cell.brandNameLabel.text = @"进口宝马";
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
