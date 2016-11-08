//
//  XCZCircleTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "XCZCityManager.h"
#import "XCZTimeTools.h"

@interface XCZCircleTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *cellHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) UILabel *headerNameLabel;
@property (weak, nonatomic) UIImageView *headerIconView;
@property (weak, nonatomic) IBOutlet UILabel *headerCityLabel;

@property (weak, nonatomic) IBOutlet UIView *cellContentView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *contentImageViews;

@property (weak, nonatomic) UILabel *forum_nameLabel;
@property (weak, nonatomic) UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *remarkCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *praiseCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *danziImageView;
@property (weak, nonatomic) IBOutlet UILabel *danziTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *danziNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *danziPriceLabel;

@end

@implementation XCZCircleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UILabel *headerNameLabel = [[UILabel alloc] init];
    headerNameLabel.font = [UIFont systemFontOfSize:14];
    headerNameLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    [self.cellHeaderView addSubview:headerNameLabel];
    self.headerNameLabel = headerNameLabel;
    
    UIImageView *headerIconView = [[UIImageView alloc] init];
    [self.cellHeaderView addSubview:headerIconView];
    self.headerIconView = headerIconView;
    
    UILabel *forum_nameLabel = [[UILabel alloc] init];
    forum_nameLabel.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    forum_nameLabel.textColor = [UIColor whiteColor];
    forum_nameLabel.font = [UIFont systemFontOfSize:10];
    [self.cellContentView addSubview:forum_nameLabel];
    self.forum_nameLabel = forum_nameLabel;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    [self.cellContentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.cellHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellHeaderViewDidClick)]];
    [self.cellContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellContentViewDidClick)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    NSLog(@"最新:%@", row);
    
    NSString *avatar;
    if ([row[@"avatar"] containsString:@"http"]) {
        avatar = row[@"avatar"];
    } else {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"avatar"]];
    }
     [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
     self.headerNameLabel.text = ((NSString *)_row[@"nick"]).length ? _row[@"nick"] : _row[@"login_name"];
    [self.headerIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [XCZConfig imgBaseURL], row[@"brand_logo"]]] placeholderImage:nil];
    CGSize headerNameLabelSize = [self.headerNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 100, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.headerNameLabel.font} context:nil].size;
    self.headerNameLabel.frame = CGRectMake(64, 12, headerNameLabelSize.width, headerNameLabelSize.height);
    self.headerIconView.frame = CGRectMake(CGRectGetMaxX(self.headerNameLabel.frame), self.headerNameLabel.frame.origin.y, self.headerNameLabel.bounds.size.height, self.headerNameLabel.bounds.size.height);
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:row[@"province_id"] cityId:row[@"city_id"] andTownId:row[@"area_id"]];
    if (!addr.length) {
        self.headerCityLabel.text = [NSString stringWithFormat:@"%@", _row[@"user_forum_name"]];
    } else {
       self.headerCityLabel.text = (((NSString *)_row[@"user_forum_name"]).length) ? [NSString stringWithFormat:@"%@ · %@", _row[@"user_forum_name"], addr] : [NSString stringWithFormat:@"%@", addr];
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"时间:   %@", row[@"create_time"]];
    self.remarkCountLabel.text = row[@"replies"];
    self.praiseCountLabel.text = row[@"goods"];
    self.contentLabel.text = row[@"summary"];
    if ([self.reuseIdentifier isEqualToString:@"CellA"] || [self.reuseIdentifier isEqualToString:@"CellA1"]  || [self.reuseIdentifier isEqualToString:@"CellA2"]) { // 多张图
        NSMutableArray *imageArray = [NSMutableArray array];
        [imageArray removeAllObjects];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
        [self setupImage:imageArray];
    } else if ([self.reuseIdentifier isEqualToString:@"CellB"]) { // 一张图s
        UIImageView *imageView = [self.contentImageViews firstObject];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], row[@"share_image"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    } else if ([self.reuseIdentifier isEqualToString:@"CellC"] || [self.reuseIdentifier isEqualToString:@"CellC1"]  || [self.reuseIdentifier isEqualToString:@"CellC2"]  || [self.reuseIdentifier isEqualToString:@"CellC3"]) { // 带产品价格
         NSDictionary *goods_remark = [self changeGoods_remark:row[@"goods_remark"]];
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], goods_remark[@"img"]];
        [self.danziImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
        self.danziTitleLabel.text = goods_remark[@"name"];
        self.danziNumLabel.text = [NSString stringWithFormat:@"共%@件", goods_remark[@"num"]];
        self.danziPriceLabel.text = [NSString stringWithFormat:@"￥%@", goods_remark[@"amount"]];
        
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
        [self setupImage:imageArray];
    } else if ([self.reuseIdentifier isEqualToString:@"CellD"]) {
        self.contentTitleLabel.text = row[@"topic"];
    }
    

    self.forum_nameLabel.text = row[@"forum_name"];
    CGSize forum_nameLabelSize = [self.forum_nameLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 64) * 0.2, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.forum_nameLabel.font} context:nil].size;
    self.forum_nameLabel.frame = CGRectMake(64, self.cellContentView.bounds.size.height - 1.0 - 20.5, forum_nameLabelSize.width, 14);
    
    NSString *creatTime = [XCZTimeTools timeWithTimeIntervalString:self.row[@"create_time"]];
    NSString *showTime = [XCZTimeTools formateDate:creatTime withFormate:@"yyyy-MM-dd HH:mm:ss"];

    self.timeLabel.text = [NSString stringWithFormat:@"时间: %@", showTime];
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.forum_nameLabel.frame) + 8, self.forum_nameLabel.frame.origin.y, 200, self.forum_nameLabel.bounds.size.height);
    
    self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.size.height * 0.5;
    self.headerImageView.layer.masksToBounds = YES;
}

- (void)cellHeaderViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleTableViewCell:cellHeaderViewDidClick:)]) {
        [self.delegate circleTableViewCell:self cellHeaderViewDidClick:self.row];
    }
}

- (void)cellContentViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleTableViewCell:cellContentViewDidClick:)]) {
        [self.delegate circleTableViewCell:self cellContentViewDidClick:self.row];
    }
}

- (NSDictionary *)changeGoods_remark:(NSString *)jsonStr
{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    
}

/**
 *  设置图片
 */
- (void)setupImage:(NSMutableArray *)imageArray
{
    for (UIImageView *imageView in self.contentImageViews) {
        imageView.image = nil;
    }
    
    if (imageArray.count <= self.contentImageViews.count) {
        for (int i = 0; i<imageArray.count; i++) {
            [self setupImageView:i andImageArray:imageArray];
        }
    } else {
        for (int i = 0; i<self.contentImageViews.count; i++) {
            [self setupImageView:i andImageArray:imageArray];
        }
    }
}

/**
 *  创建图片方法
 */
- (void)setupImageView:(int)i andImageArray:(NSArray *)imageArray
{
    UIImageView *imageView = self.contentImageViews[i];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *imageYStr = imageArray[i];
    NSString *imageStr;
    if ([imageYStr containsString:@"http"]) {
        imageStr = imageYStr;
    } else {
        imageStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL],imageArray[i]];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
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
