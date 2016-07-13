//
//  AddMyCarViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "AddMyCarViewController.h"

@interface AddMyCarViewController ()

@end

@implementation AddMyCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = @"添加车型";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
