//
//  DiscoveryViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "Config.h"

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/bbs/index.html"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
