//
//  XCZPersonInfoViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZPersonInfoViewCell()

@property (weak, nonatomic) IBOutlet UILabel *dayMonthLabel;

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIView *imageBackView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;


@end

@implementation XCZPersonInfoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

    //                        content = "";
    //                        "create_time" = "2016-05-19 08:22:35";
    //                        "img_num" = 1;
    //                        "main_image" = "";
    //                        "share_image" = "group1/M00/00/3C/wKgCBFc9BzeAWPFQAAkVVGMybN8653.jpg,group1/M00/00/3C/wKgCBFc9BzWAI5fkAA1rIuRd3Es362.jpg,group1/M00/00/3C/wKgCBFc9BzGAUyBuAABbqSuxB_w623.jpg,group1/M00/00/3C/wKgCBFc9ByeAJib_AAAmDFN54ig009.jpg,group1/M00/00/3C/wKgCBFc9ByaAeWI2AAAo5JEb2Iw356.jpg,group1/M00/00/3C/wKgCBFc9BySAeda1AABmxSAs794086.jpg";
    //                        topic = "";
    //                    },

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    [self clearData];
    [self setupSubView];
}

- (void)clearData
{
    self.dayMonthLabel.text = @"";
    self.dayLabel.text = @"";
    self.monthLabel.text = @"";
    for (int i = 0; i<self.imageBackView.subviews.count; i++) {
        UIImageView *imageView = self.imageBackView.subviews[i];
        [imageView removeFromSuperview];
        imageView = nil;
    }
}

- (void)setupSubView
{

    for (UIView *cellView in self.imageBackView.subviews) {
        [cellView removeFromSuperview];
    }

    if (self.indexPath.row) {
        self.dayMonthLabel.text = @"";
        self.dayLabel.text = @"";
        self.monthLabel.text = @"";
    } else {
        if (((NSString *)_row[@"dateStr"]).length) {
            self.dayMonthLabel.text = _row[@"dateStr"];
        } else {
            self.dayLabel.text = _row[@"day"];
            self.monthLabel.text = [NSString stringWithFormat:@"%@", _row[@"month"]];
        }
    }
    self.contentLabel.text = _row[@"content"];
    NSString *post_clazz = _row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        
    } else if ([post_clazz intValue] == 3) {
        NSArray *images = _row[@"images"];
        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:[images firstObject]]];
        UIImage *image = [UIImage imageWithData:data];
        CGFloat oneImageW = image.size.width;
        CGFloat oneImageH = image.size.height;
        //        NSLog(@"oneImageW:%f, oneImageH:%f", oneImageW, oneImageH);
        if (images.count == 1) {
            UIImageView *oneImgView = [[UIImageView alloc] init];
            oneImgView.image = image;
            oneImgView.contentMode = UIViewContentModeScaleAspectFit;
            oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height);
            [self.imageBackView addSubview:oneImgView];
            
        } else if (images.count == 2) {
            if (oneImageW >= oneImageH) {
                UIImageView *oneImgView = [[UIImageView alloc] init];
                oneImgView.image = image;
                oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                [self.imageBackView addSubview:oneImgView];
                
                UIImageView *twoImgView = [[UIImageView alloc] init];
                [twoImgView sd_setImageWithURL:[NSURL URLWithString:[images lastObject]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                twoImgView.frame = CGRectMake(0, self.imageBackView.bounds.size.height * 0.5 + 4, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                [self.imageBackView addSubview:twoImgView];
                
            } else if (oneImageW < oneImageH) {
                UIImageView *oneImgView = [[UIImageView alloc] init];
                oneImgView.image = image;
                oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                [self.imageBackView addSubview:oneImgView];
                
                UIImageView *twoImgView = [[UIImageView alloc] init];
                [twoImgView sd_setImageWithURL:[NSURL URLWithString:[images lastObject]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                twoImgView.frame = CGRectMake(self.imageBackView.bounds.size.height * 0.5 + 4, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                [self.imageBackView addSubview:twoImgView];
                
            }
        } else if (images.count == 3) {
            if (oneImageW >= oneImageH) {
                UIImageView *oneImgView = [[UIImageView alloc] init];
                oneImgView.image = image;
                oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                [self.imageBackView addSubview:oneImgView];
                for (int i = 0; i<2; i++) {
                    UIImageView *imgView = [[UIImageView alloc] init];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:images[i+1]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                    CGFloat imgViewW = self.imageBackView.bounds.size.width * 0.5 - 4;
                    imgView.frame = CGRectMake(i * (imgViewW + 8), self.imageBackView.bounds.size.height * 0.5 + 4, imgViewW, imgViewW);
                    [self.imageBackView addSubview:imgView];
                }
            } else {
                UIImageView *oneImgView = [[UIImageView alloc] init];
                oneImgView.image = image;
                oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                [self.imageBackView addSubview:oneImgView];
                for (int i = 0; i<2; i++) {
                    UIImageView *imgView = [[UIImageView alloc] init];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:images[i+1]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                    CGFloat imgViewW = self.imageBackView.bounds.size.height * 0.5 - 4;
                    imgView.frame = CGRectMake(self.imageBackView.bounds.size.height * 0.5 + 4, i * (imgViewW + 8), imgViewW, imgViewW);
                    [self.imageBackView addSubview:imgView];
                }
            }
        } else if(images.count == 4) {
            for (int i=0; i<4; i++) {
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:nil];
                CGFloat imgViewW = self.imageBackView.bounds.size.height * 0.5 - 4;
                CGFloat hanghao = i/2;
                CGFloat liehao = i%2;
                imgView.frame = CGRectMake(liehao * (imgViewW + 8), hanghao * (imgViewW + 8), imgViewW, imgViewW);
                [self.imageBackView addSubview:imgView];
            }
        }

        
        
        id o = self;
        
        /*
        UIImageView *oneImgView = [[UIImageView alloc] init];
        oneImgView.image = image;
        oneImgView.contentMode = UIViewContentModeScaleAspectFit;
        oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height);
        [self.imageBackView addSubview:oneImgView];
         */
        
        
        /*
        [oneYImgView sd_setImageWithURL:[NSURL URLWithString:[images firstObject]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGFloat oneImageW = image.size.width;
            CGFloat oneImageH = image.size.height;
            //        NSLog(@"oneImageW:%f, oneImageH:%f", oneImageW, oneImageH);
            if (images.count == 1) {
                UIImageView *oneImgView = [[UIImageView alloc] init];
                oneImgView.image = image;
                oneImgView.contentMode = UIViewContentModeScaleAspectFit;
                oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height);
                [self.imageBackView addSubview:oneImgView];
                
            } else if (images.count == 2) {
                if (oneImageW >= oneImageH) {
                    UIImageView *oneImgView = [[UIImageView alloc] init];
                    oneImgView.image = image;
                    oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                    [self.imageBackView addSubview:oneImgView];
                    
                    UIImageView *twoImgView = [[UIImageView alloc] init];
                    [twoImgView sd_setImageWithURL:[NSURL URLWithString:[images lastObject]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                    twoImgView.frame = CGRectMake(0, self.imageBackView.bounds.size.height * 0.5 + 4, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                    [self.imageBackView addSubview:twoImgView];
                    
                } else if (oneImageW < oneImageH) {
                    UIImageView *oneImgView = [[UIImageView alloc] init];
                    oneImgView.image = image;
                    oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                    [self.imageBackView addSubview:oneImgView];
                    
                    UIImageView *twoImgView = [[UIImageView alloc] init];
                    [twoImgView sd_setImageWithURL:[NSURL URLWithString:[images lastObject]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                    twoImgView.frame = CGRectMake(self.imageBackView.bounds.size.height * 0.5 + 4, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                    [self.imageBackView addSubview:twoImgView];
                    
                }
            } else if (images.count == 3) {
                if (oneImageW >= oneImageH) {
                    UIImageView *oneImgView = [[UIImageView alloc] init];
                    oneImgView.image = image;
                    oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width, self.imageBackView.bounds.size.height * 0.5 - 4);
                    [self.imageBackView addSubview:oneImgView];
                    for (int i = 0; i<2; i++) {
                        UIImageView *imgView = [[UIImageView alloc] init];
                        [imgView sd_setImageWithURL:[NSURL URLWithString:images[i+1]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                        CGFloat imgViewW = self.imageBackView.bounds.size.width * 0.5 - 4;
                        imgView.frame = CGRectMake(i * (imgViewW + 8), self.imageBackView.bounds.size.height * 0.5 + 4, imgViewW, imgViewW);
                        [self.imageBackView addSubview:imgView];
                    }
                } else {
                    UIImageView *oneImgView = [[UIImageView alloc] init];
                    oneImgView.image = image;
                    oneImgView.frame = CGRectMake(0, 0, self.imageBackView.bounds.size.width * 0.5 - 4, self.imageBackView.bounds.size.height);
                    [self.imageBackView addSubview:oneImgView];
                    for (int i = 0; i<2; i++) {
                        UIImageView *imgView = [[UIImageView alloc] init];
                        [imgView sd_setImageWithURL:[NSURL URLWithString:images[i+1]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
                        CGFloat imgViewW = self.imageBackView.bounds.size.height * 0.5 - 4;
                        imgView.frame = CGRectMake(self.imageBackView.bounds.size.height * 0.5 + 4, i * (imgViewW + 8), imgViewW, imgViewW);
                        [self.imageBackView addSubview:imgView];
                    }
                }
            } else if(images.count == 4) {
                for (int i=0; i<4; i++) {
                    UIImageView *imgView = [[UIImageView alloc] init];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:nil];
                    CGFloat imgViewW = self.imageBackView.bounds.size.height * 0.5 - 4;
                    CGFloat hanghao = i/2;
                    CGFloat liehao = i%2;
                    imgView.frame = CGRectMake(liehao * (imgViewW + 8), hanghao * (imgViewW + 8), imgViewW, imgViewW);
                    [self.imageBackView addSubview:imgView];
                }
            }
        }];
         */
    } else if ([post_clazz intValue] == 4) {
        NSDictionary *goods_remark = [NSJSONSerialization JSONObjectWithData:[_row[@"goods_remark"] dataUsingEncoding:NSUTF8StringEncoding]
                                        options:NSJSONReadingMutableContainers
                                          error:nil];
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], goods_remark[@"img"]];
        [self.productImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
        self.productContentLabel.text = goods_remark[@"name"];
        self.productNumLabel.text = [NSString stringWithFormat:@"共%@件", goods_remark[@"num"]];
        self.productPriceLabel.text = [NSString stringWithFormat:@"￥%@", goods_remark[@"amount"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
