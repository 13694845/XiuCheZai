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

static NSString *const kBaseURL = @"http://m.8673h.com";
static NSString *const kVersion = @"1.4.0";

+ (NSString *)baseURL {
    return kBaseURL;
}

+ (NSString *)version {
    return kVersion;
}

@end
