//
//  XCZPublishBrandsTableViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishBrandsTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface XCZPublishBrandsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;


@end

@implementation XCZPublishBrandsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    [self.pictureImageView sd_setImageWithURL:[NSURL URLWithString:[row objectForKey:@"forum_style"]] placeholderImage:nil];
    self.nameLabel.text = [row objectForKey:@"forum_name"];
    self.remarkLabel.text = [row objectForKey:@"forum_remark"];
}

@end
