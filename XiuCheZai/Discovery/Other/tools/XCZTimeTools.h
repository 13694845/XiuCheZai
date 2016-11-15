//
//  XCZTimeTools.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZTimeTools : NSObject



/** 13位(毫秒)时间戳转化为时间 yyyy-MM-dd HH:mm:ss */
+ (NSString *)timeWithTimeIntervalString:(NSString *)time13String;
/** 将时间转化为今天，昨天这种形式 */
+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *)formate;
/** 将时间转化为今天，昨天这种形式(图片浏览器里) */
+ (NSString *)formateDatePicture:(NSString *)dateString withFormate:(NSString *)formate;

@end
