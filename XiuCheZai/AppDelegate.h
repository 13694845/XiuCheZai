//
//  AppDelegate.h
//  XiuCheZai
//
//  Created by QSH on 15/12/2.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "ChatService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) id <WXApiDelegate> wxApiDelegate;
@property (strong, nonatomic) BMKMapManager *mapManager;
@property (strong, nonatomic) ChatService *chatService;

@end
