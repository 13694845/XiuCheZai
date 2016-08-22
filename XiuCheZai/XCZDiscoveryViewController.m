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
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (assign, nonatomic) int currentIndex;

@end

@implementation XCZDiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    
    for (UIButton *button in self.buttons) [button addTarget:self action:@selector(switchContent:) forControlEvents:UIControlEventTouchUpInside];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleViewController"]];
    
    UIViewController *viewController = self.childViewControllers.firstObject;
    viewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:viewController.view];
}

- (void)switchContent:(id)sender {
    UIViewController *viewController = self.childViewControllers[self.currentIndex];
    
    CGRect rect = viewController.view.frame;
    rect.origin.x = rect.size.width;
    // viewController.view.frame = rect;
    
    // rect.origin.x = 0;
    [UIView animateWithDuration:0.3 animations:^{
        viewController.view.frame = rect;
    }];
    // [viewController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
