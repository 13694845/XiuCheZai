//
//  XCZNewsTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsTableViewCell.h"

@interface XCZNewsTableViewCell ()

@property (weak, nonatomic) IBOutlet NSString *newsTitle;
@property (weak, nonatomic) IBOutlet NSString *publishDate;
@property (weak, nonatomic) IBOutlet NSString *reprintFrom;
@property (weak, nonatomic) IBOutlet NSString *newsText;
@property (weak, nonatomic) IBOutlet NSArray *admiredPersons;
@property (weak, nonatomic) IBOutlet NSArray *newsRemarks;




@end

@implementation XCZNewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
