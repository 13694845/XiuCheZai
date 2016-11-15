//
//  XCZContentViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface XCZDiscoveryPageViewController : UIViewController

@property (strong, nonatomic) AFHTTPSessionManager *manager;

//@property(nonatomic, strong)NSDictionary *message;
- (void)shareMessage:(NSDictionary *)message;

@end
