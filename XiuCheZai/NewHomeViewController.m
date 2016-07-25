//
//  NewHomeViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "NewHomeViewController.h"

@interface NewHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *newsView;

@end

@implementation NewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsView.layer.cornerRadius = 3.5;
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21/255.0 blue:45.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
