//
//  Config.h
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (NSString *)baseURL;
+ (NSString *)apiBaseURL;
+ (NSString *)version;
+ (NSArray *)banners;

@end
