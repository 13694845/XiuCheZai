//
//  XCZPersonInfoLookImageViewController.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  图片查看控制器
//

#import "XCZDiscoveryPageViewController.h"

@interface XCZPersonInfoLookImageViewController : XCZDiscoveryPageViewController

@property (nonatomic, strong) NSDictionary *row;
///** 删除后跳转到我的话题 */
@property (nonatomic, assign) BOOL deleteJumpToMessageMyTopic;


@end
