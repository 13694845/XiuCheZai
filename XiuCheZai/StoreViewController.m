//
//  StoreViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "StoreViewController.h"
#import "Config.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/service/index/index.html"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
