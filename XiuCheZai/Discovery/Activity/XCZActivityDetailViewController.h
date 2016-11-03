//
//  XCZCircleDetailViewController.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/9.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  话题详情
//

#import "XCZDiscoveryPageViewController.h"

@protocol XCZActivityDetailViewControllerDelegate <NSObject>
@optional
- (void)detailViewController:(UIViewController *)viewController bottomTextField:(UITextField *)bottomTextField;
@end

@interface XCZActivityDetailViewController : XCZDiscoveryPageViewController

@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, weak) id<XCZActivityDetailViewControllerDelegate> delegate;

@end
