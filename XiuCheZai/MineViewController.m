//
//  MineViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/1/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "MineViewController.h"
#import "Config.h"

@interface MineViewController ()

@end

@implementation MineViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_index/index.html"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
