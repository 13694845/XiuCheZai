//
//  AppDelegate.h
//  XiuCheZai
//
//  Created by QSH on 15/12/2.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) id <WXApiDelegate> wxApiDelegate;

@end
