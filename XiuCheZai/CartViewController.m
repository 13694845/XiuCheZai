//
//  CartViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/1/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "CartViewController.h"
#import "Config.h"

@interface CartViewController ()

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
