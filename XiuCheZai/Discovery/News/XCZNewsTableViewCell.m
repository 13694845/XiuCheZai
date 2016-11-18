//
//  XCZNewsTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

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
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    if ([self.reuseIdentifier isEqualToString:@"CellA"]) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:self.row[@"art_img"] andImageArray:imageArray];
        self.newsTitleLabel.text = self.row[@"art_title"];
        self.reprintFromLabel.text = ((NSString *)self.row[@"art_origin"]).length ? self.row[@"art_origin"] : self.row[@"art_author"];
        if (!self.reprintFromLabel.text.length) {
            self.reprintFromLabel.text = @"佚名";
        }
        
        self.remarkCountLabel.text = self.row[@"replies"];
        self.praiseCountLabel.text = self.row[@"goods"];
        for (int i = 0; i<imageArray.count; i++) {
            UIImageView *imageView = self.newsImageViews[i];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            NSString *imageStr;
            if ([imageArray[i] containsString:@"http"]) {
                imageStr = [NSString stringWithFormat:@"%@", imageArray[i]];
            } else {
                imageStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], imageArray[i]];
            }
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil];
        }
    }
    
    if ([self.reuseIdentifier isEqualToString:@"CellB"]) {
        self.newsTitleLabel.text = self.row[@"art_title"];
        self.reprintFromLabel.text = ((NSString *)self.row[@"art_origin"]).length ? self.row[@"art_origin"] : self.row[@"art_author"];
        if (!self.reprintFromLabel.text.length) {
            self.reprintFromLabel.text = @"佚名";
        }
        self.remarkCountLabel.text = self.row[@"replies"];
        self.praiseCountLabel.text = self.row[@"goods"];
        UIImageView *imageView = [self.newsImageViews firstObject];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        NSString *imageStr;
        if ([self.row[@"art_img"] containsString:@"http"]) {
            imageStr = [NSString stringWithFormat:@"%@", self.row[@"art_img"]];
        } else {
            imageStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], self.row[@"art_img"]];
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"bbs_newsDefault.jpg"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [imageArray addObject:[imageStrs substringToIndex:range.location]];
        [self changeImage:[imageStrs substringFromIndex:(range.location + 1)] andImageArray:imageArray];
    } else {
        [imageArray addObject:imageStrs];
    }
    return imageArray;
}


@end
