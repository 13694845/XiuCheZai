//
//  Config.m
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "Config.h"

@interface Config ()

@end

@implementation Config

static NSString *const kVersion = @"1.4.0";
static NSString *const kWebBaseURL = @"http://m.8673h.com";
static NSString *const kApiBaseURL = @"http://m.8673h.com";
static NSString *const kImgBaseURL = @"http://img.8673h.com";

+ (NSString *)version {
    return kVersion;
}

+ (NSString *)baseURL {
    return kWebBaseURL;
}

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
