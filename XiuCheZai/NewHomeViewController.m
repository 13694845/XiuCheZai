//
//  NewHomeViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "NewHomeViewController.h"

@interface NewHomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *newsView;

@end

@implementation NewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.scrollView.contentSize = self.mainView.bounds.size;
    self.newsView.layer.cornerRadius = 3.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
