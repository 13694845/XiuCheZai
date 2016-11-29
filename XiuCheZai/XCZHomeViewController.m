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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation XCZHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    /*
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = self.mainView.bounds.size;
     */
    // NSLog(@"scrollView : %@", NSStringFromCGRect(self.scrollView.frame));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // NSLog(@"scrollView : %@", NSStringFromCGRect(self.scrollView.frame));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // NSLog(@"scrollView : %@", NSStringFromCGRect(self.scrollView.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
