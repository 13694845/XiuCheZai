//
//  XCZConfig.m
//  XiuCheZai
//
//  Created by QSH on 16/9/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZConfig.h"

@implementation XCZConfig

static NSString *const kWebBaseURL = @"http://m.8673h.com";
static NSString *const kApiBaseURL = @"http://m.8673h.com";
static NSString *const kImgBaseURL = @"http://img.8673h.com";
static NSString *const kTestBaseURL = @"http://192.168.2.4:8080";

+ (NSString *)webBaseURL {
    return kWebBaseURL;
}

+ (NSString *)apiBaseURL {
    return kApiBaseURL;
}

+ (NSString *)imgBaseURL {
    return kImgBaseURL;
}

@end
