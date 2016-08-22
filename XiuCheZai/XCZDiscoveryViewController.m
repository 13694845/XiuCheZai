//
//  XCZDiscoveryViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDiscoveryViewController.h"
#import "XCZNewsViewController.h"
#import "XCZCircleViewController.h"

@interface XCZDiscoveryViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) XCZNewsViewController *newsViewController;
@property (nonatomic, strong) XCZCircleViewController *circleViewController;

@end

@implementation XCZDiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    
    self.newsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsViewController"];
    [self addChildViewController:self.newsViewController];
    self.newsViewController.view.frame = self.contentView.frame;
//    [self.view addSubview:self.newsViewController.view];


    self.circleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleViewController"];
    [self addChildViewController:self.circleViewController];
    self.circleViewController.view.frame = self.contentView.frame;
    [self.view addSubview:self.circleViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
