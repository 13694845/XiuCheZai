//
//  SeriesSelectorViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "SeriesSelectorViewController.h"
#import "Config.h"
#import "AFNetworking.h"

@interface SeriesSelectorViewController ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSMutableArray *series;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SeriesSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
