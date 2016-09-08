//
//  XCZNewsTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsTableViewCell.h"

@interface XCZNewsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *newsImageViews;
@property (weak, nonatomic) IBOutlet UILabel *reprintFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *praiseCountLabel;

@end

@implementation XCZNewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    /*
    // self.reuseIdentifier = @"CellA"
    // self.reuseIdentifier = @"CellB"
    */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
