//
//  TabBarController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/8.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "TabBarController.h"
#import "XCZConfig.h"

@interface TabBarController () <UITabBarControllerDelegate>

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discovery" bundle:nil];
    UIViewController *discoveryViewController = [storyboard instantiateViewControllerWithIdentifier:@"XCZDiscoveryFrameViewController"];
    UINavigationController *discoverynavigationController = self.viewControllers[TabIndexDiscovery];
    [discoverynavigationController setViewControllers:@[discoveryViewController] animated:NO];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == [tabBarController.viewControllers firstObject]) {
        [(UINavigationController *)viewController popViewControllerAnimated:NO];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
