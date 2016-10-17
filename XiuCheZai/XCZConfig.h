//
//  XCZConfig.h
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZConfig : NSObject

typedef NS_ENUM(int, TabIndex) {
    TabIndexHome = 0,
    TabIndexStore,
    TabIndexDiscovery,
    TabIndexAccessory,
    TabIndexMine,
    TabIndexCart
};

+ (NSString *)version;
+ (NSString *)baseURL;
+ (NSString *)webBaseURL;
+ (NSString *)apiBaseURL;
+ (NSString *)imgBaseURL;

@end
