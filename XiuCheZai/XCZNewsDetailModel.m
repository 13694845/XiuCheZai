//
//  XCZNewsDetailModel.m
//  XiuCheZai
//
//  Created by QSH on 16/9/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsDetailModel.h"

@interface XCZNewsDetailModel ()

@property (nonatomic, strong) NSString *newsTitle;
@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, strong) NSString *reprintFrom;
@property (nonatomic, strong) NSString *newsText;
@property (nonatomic, strong) NSArray *admiredPersons;
@property (nonatomic, strong) NSArray *newsRemarks;

@end

@implementation XCZNewsDetailModel

- (NSString *)newsTitle {
    return @"文章标题文章标题文章标题题文章标题题文章标题";
}

- (NSString *)publishDate {
    return @"昨天 14：36";
}

- (NSString *)reprintFrom {
    return @"新浪汽车";
}

- (NSString *)newsText {
    return @"<h1>news text here.</h1>";
}

- (NSArray *)admiredPersons {
    return nil;
}

- (NSArray *)newsRemarks {
    return nil;
}

@end
