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
    TabIndexStore,
    TabIndexAccessory,
    TabIndexCart,
    TabIndexMine
};

+ (NSString *)baseURL;
+ (NSString *)version;
+ (NSArray *)banners;

@end
