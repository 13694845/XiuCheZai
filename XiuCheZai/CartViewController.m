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

- (void)awakeFromNib {
    [super awakeFromNib];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
