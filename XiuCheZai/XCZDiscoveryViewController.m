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
    UIViewController *currentViewController = self.childViewControllers[self.currentIndex];
    
    int newIndex = [self.buttons indexOfObject:sender];
    UIViewController *newViewController = self.childViewControllers[newIndex];
    
    /*
    [self transitionFromViewController:currentViewController toViewController:newViewController duration:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = self.contentView.bounds;
        rect.origin.x -= self.contentView.bounds.size.width;
        currentViewController.view.frame = rect;

        
    } completion:^(BOOL finished) {
    }];
    */
    
    CGRect rect = self.contentView.bounds;
    
    if (newIndex > self.currentIndex) {
        
    }
    
    rect.origin.x += self.contentView.bounds.size.width;
    newViewController.view.frame = rect;
    [self.contentView addSubview:newViewController.view];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.contentView.bounds;
        rect.origin.x -= self.contentView.bounds.size.width;
        currentViewController.view.frame = rect;
        newViewController.view.frame = self.contentView.bounds;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
