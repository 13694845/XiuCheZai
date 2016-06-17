//
//  AccessoryViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/1/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "AccessoryViewController.h"
#import "Config.h"

@interface AccessoryViewController ()

@end

@implementation AccessoryViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Car_Brand/index.html"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
