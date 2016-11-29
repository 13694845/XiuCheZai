//
//  XCZHomeViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZHomeViewController.h"

@interface XCZHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation XCZHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    /*
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = self.mainView.bounds.size;
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end