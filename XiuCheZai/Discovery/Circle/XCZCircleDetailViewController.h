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

@protocol XCZCircleDetailViewControllerDelegate <NSObject>

@optional
- (void)detailViewController:(UIViewController *)viewController bottomTextField:(UITextField *)bottomTextField;
@end

@interface XCZCircleDetailViewController : XCZDiscoveryPageViewController

@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, assign) BOOL jumpToHome;
/** 删除后跳转到上一级 */
@property (nonatomic, assign) BOOL deleteJumpToUpper;
///** 删除后跳转到我的话题 */
@property (nonatomic, assign) BOOL deleteJumpToMessageMyTopic;

@property (nonatomic, weak) id<XCZCircleDetailViewControllerDelegate> delegate;

@end
