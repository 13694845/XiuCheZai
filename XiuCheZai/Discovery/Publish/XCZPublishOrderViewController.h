//
//  XCZPublishOrderTopicViewController.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDiscoveryPageViewController.h"

@interface XCZPublishOrderViewController : XCZDiscoveryPageViewController

/** 1.整单 2:非整单 */
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSDictionary *order_good;


@end
