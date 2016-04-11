//
//  URLCache.m
//  XiuCheZai
//
//  Created by QSH on 16/4/5.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "URLCache.h"

static NSString *const kRedirectRequestKey = @"redirectRequest";
static NSString *const kResponseKey = @"response";
static NSString *const kDataKey = @"data";

@implementation URLCache

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _redirectRequest = [aDecoder decodeObjectForKey:kRedirectRequestKey];
        _response = [aDecoder decodeObjectForKey:kResponseKey];
        _data = [aDecoder decodeObjectForKey:kDataKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.redirectRequest forKey:@"redirectRequest"];
    [aCoder encodeObject:self.response forKey:@"response"];
    [aCoder encodeObject:self.data forKey:@"data"];
}

@end
