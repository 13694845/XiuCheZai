//
//  XCZPublishBrandsViewController.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  发布部分车友会控制器
//

#import "XCZDiscoveryPageViewController.h"


@protocol XCZPublishBrandsViewControllerDelegate <NSObject>

@optional
- (void)publishBrandsViewController:(UIViewController *)viewController didSelectRow:(NSDictionary *)row;

@end

@interface XCZPublishBrandsViewController : XCZDiscoveryPageViewController

@property (nonatomic, weak) id<XCZPublishBrandsViewControllerDelegate> delegate;

@end
