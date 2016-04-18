//
//  Config.h
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (NSString *)version;
+ (NSString *)baseURL;
+ (NSString *)webBaseURL;
+ (NSString *)apiBaseURL;
+ (NSString *)imgBaseURL;

@end
