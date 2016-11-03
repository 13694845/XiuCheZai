//
//  XCZNewsDetailViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  资讯详情
//

#import "XCZDiscoveryPageViewController.h"

@protocol XCZNewsDetailViewControllerDelegate <NSObject>

@optional
- (void)detailViewController:(UIViewController *)viewController bottomTextField:(UITextField *)bottomTextField;

@end

@interface XCZNewsDetailViewController : XCZDiscoveryPageViewController

@property (nonatomic, copy) NSString *artid;
@property (nonatomic, weak) id<XCZNewsDetailViewControllerDelegate> delegate;

@end
