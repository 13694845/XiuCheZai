//
//  Config.h
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

typedef NS_ENUM(int, TabIndex) {
    TabIndexHome = 0,
    TabIndexStore = 1,
    TabIndexDiscovery = 2,
    TabIndexAccessory = 3,
    TabIndexMine = 4,
    TabIndexCart
};

+ (NSString *)version;
+ (NSString *)baseURL;
+ (NSString *)webBaseURL;
+ (NSString *)apiBaseURL;
+ (NSString *)imgBaseURL;

@end
