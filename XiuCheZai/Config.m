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

static NSString *const kAppVersion = @"1.9.6";
static NSString *const kVersion = @"1.6.0";
static NSString *const kWebBaseURL = @"http://m.8673h.com";
static NSString *const kApiBaseURL = @"http://m.8673h.com";
static NSString *const kImgBaseURL = @"http://img.8673h.com";

static NSString *const kTestBaseURL = @"http://192.168.2.4:8080";
static NSString *const kTestImgBaseURL = @"http://192.168.2.4:8888";
static NSString *const kDomainBaseURL = @"http://a.zj-qsh.com";

+ (NSString *)appVersion {
    return kAppVersion;
}

+ (NSString *)version {
    return kVersion;
}

+ (NSString *)baseURL {
    return kTestBaseURL;
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

+ (NSString *)textImgBaseURL {
    return [self imgBaseURL];
}

@end
