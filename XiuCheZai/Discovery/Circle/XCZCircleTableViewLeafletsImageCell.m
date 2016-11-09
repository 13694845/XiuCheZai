//
//  XCZCircleTableViewLeafletsImageCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleTableViewLeafletsImageCell.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "DiscoveryConfig.h"
#import "XCZCityManager.h"
#import "XCZTimeTools.h"

@interface XCZCircleTableViewLeafletsImageCell()

@property (weak, nonatomic) UIView *cellHeaderView;
@property (weak, nonatomic) UIImageView *headerImageView;
@property (weak, nonatomic) UILabel *headerNameLabel;
@property (weak, nonatomic) UIImageView *headerIconView;
@property (weak, nonatomic) UILabel *headerCityLabel;
@property (weak, nonatomic) UIView *cellContentView;
@property (weak, nonatomic) UIImageView *contentImageView;
@property (weak, nonatomic) UILabel *contentTitleLabel;
@property (weak, nonatomic) UILabel *contentLabel;
@property (weak, nonatomic) UILabel *praiseTextLabel;
@property (weak, nonatomic) UIImageView *praiseImageView;
@property (weak, nonatomic) UILabel *commentTextLabel;
@property (weak, nonatomic) UIImageView *commentImageView;
@property (weak, nonatomic) UILabel *forum_nameLabel;
@property (weak, nonatomic) UILabel *timeLabel;

@property (weak, nonatomic) UIView *bottomLineView;

@end

@implementation XCZCircleTableViewLeafletsImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *cellHeaderView = [[UIView alloc] init];
        [self addSubview:cellHeaderView];
        self.cellHeaderView = cellHeaderView;
        
        UIImageView *headerImageView = [[UIImageView alloc] init];
        headerImageView.backgroundColor = [UIColor lightGrayColor];
        [cellHeaderView addSubview:headerImageView];
        self.headerImageView = headerImageView;
        
        UILabel *headerNameLabel = [[UILabel alloc] init];
        headerNameLabel.font = [UIFont systemFontOfSize:14];
        headerNameLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        [cellHeaderView addSubview:headerNameLabel];
        self.headerNameLabel = headerNameLabel;
        
        UIImageView *headerIconView = [[UIImageView alloc] init];
        [cellHeaderView addSubview:headerIconView];
        self.headerIconView = headerIconView;
        
        UILabel *headerCityLabel = [[UILabel alloc] init];
        headerCityLabel.font = [UIFont systemFontOfSize:10];
        headerCityLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [cellHeaderView addSubview:headerCityLabel];
        self.headerCityLabel = headerCityLabel;
        
        UIView *cellContentView = [[UIView alloc] init];
        [self addSubview:cellContentView];
        self.cellContentView = cellContentView;
        
        UIImageView *contentImageView = [[UIImageView alloc] init];
        [self.cellContentView addSubview:contentImageView];
        self.contentImageView = contentImageView;
        
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
        
        UILabel *contentTitleLabel = [[UILabel alloc] init];
        contentTitleLabel.numberOfLines = 2;
        contentTitleLabel.font = [UIFont systemFontOfSize:18];
        contentTitleLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        [cellContentView addSubview:contentTitleLabel];
        self.contentTitleLabel = contentTitleLabel;
        
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.numberOfLines = 5;
        contentLabel.font = [UIFont systemFontOfSize:18];
        contentLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        [cellContentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        UILabel *praiseTextLabel = [[UILabel alloc] init];
        praiseTextLabel.font = [UIFont systemFontOfSize:10];
        praiseTextLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        [self.cellContentView addSubview:praiseTextLabel];
        self.praiseTextLabel = praiseTextLabel;
        
        UIImageView *praiseImageView = [[UIImageView alloc] init];
        praiseImageView.image = [UIImage imageNamed:@"bbs_like.png"];
        [self.cellContentView addSubview:praiseImageView];
        self.praiseImageView = praiseImageView;
        
        UILabel *commentTextLabel = [[UILabel alloc] init];
        commentTextLabel.font = [UIFont systemFontOfSize:10];
        commentTextLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        [self.cellContentView addSubview:commentTextLabel];
        self.commentTextLabel = commentTextLabel;
        
        UIImageView *commentImageView = [[UIImageView alloc] init];
        commentImageView.image = [UIImage imageNamed:@"bbs_message.png"];
        [self.cellContentView addSubview:commentImageView];
        self.commentImageView = commentImageView;
        
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [cellContentView addSubview:bottomLineView];
        self.bottomLineView = bottomLineView;
        
        [self.cellHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellHeaderViewDidClick)]];
        [self.cellContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellContentViewDidClick)]];
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    [self setupAttrAndFrame];
}

- (void)setupAttrAndFrame
{
    NSString *avatar;
    if ([_row[@"avatar"] containsString:@"http"]) {
        avatar = _row[@"avatar"];
    } else {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], _row[@"avatar"]];
    }
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
     self.headerNameLabel.text = ((NSString *)_row[@"nick"]).length ? _row[@"nick"] : _row[@"login_name"];
    if ([_row[@"brand_name"] isEqualToString:@""]) {
        self.headerIconView.image = nil;
    } else {
        [self.headerIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [XCZConfig imgBaseURL], _row[@"brand_logo"]]] placeholderImage:nil];
        CGSize headerNameLabelSize = [self.headerNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 100, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.headerNameLabel.font} context:nil].size;
        self.headerNameLabel.frame = CGRectMake(64, 12, headerNameLabelSize.width, headerNameLabelSize.height);
        self.headerIconView.frame = CGRectMake(CGRectGetMaxX(self.headerNameLabel.frame), self.headerNameLabel.frame.origin.y, self.headerNameLabel.bounds.size.height, self.headerNameLabel.bounds.size.height);
    }
    
    NSString *user_forum_name = ((NSString *)_row[@"user_forum_name"]).length ? _row[@"user_forum_name"] : @"修车仔";
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:@"" cityId:_row[@"city_id"] andTownId:_row[@"area_id"]];
    if (!addr.length) {
        self.headerCityLabel.text = [NSString stringWithFormat:@"%@", user_forum_name];
    } else {
        self.headerCityLabel.text = [NSString stringWithFormat:@"%@ · %@", user_forum_name, addr];
    }
    
    self.contentTitleLabel.text = _row[@"topic"];
    self.contentLabel.text = _row[@"summary"];
    
    self.cellHeaderView.frame = CGRectMake(0, 8, self.selfW, 56);
    self.headerImageView.frame = CGRectMake(16, 8, 40, 40);
    self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.size.height * 0.5;
    self.headerImageView.layer.masksToBounds = YES;
    
    CGSize headerNameLabelSize = [self.headerNameLabel.text boundingRectWithSize:CGSizeMake(self.selfW - 64 - 30, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.headerNameLabel.font} context:nil].size;
    self.headerNameLabel.frame = CGRectMake(64, 12, headerNameLabelSize.width, headerNameLabelSize.height);
    self.headerIconView.frame = CGRectMake(CGRectGetMaxX(self.headerNameLabel.frame) + 4, self.headerNameLabel.frame.origin.y, self.headerNameLabel.bounds.size.height, self.headerNameLabel.bounds.size.height);
    
    CGSize headerCityLabelSize = [self.headerCityLabel.text boundingRectWithSize:CGSizeMake(self.selfW - 56 * 2, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.headerCityLabel.font} context:nil].size;
    self.headerCityLabel.frame = CGRectMake(self.headerNameLabel.frame.origin.x, CGRectGetMaxY(self.headerNameLabel.frame) + 4, headerCityLabelSize.width, headerCityLabelSize.height);
    
    CGFloat contentLabelY = 0.0;
    if (self.contentTitleLabel.text && self.contentTitleLabel.text.length) {
        CGSize contentTitleLabelSize = [self.contentTitleLabel.text boundingRectWithSize:CGSizeMake(self.selfW - 64 - 8, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.contentTitleLabel.font} context:nil].size;
        self.contentTitleLabel.frame = CGRectMake(64, 0, contentTitleLabelSize.width, contentTitleLabelSize.height);
        contentLabelY = CGRectGetMaxY(self.contentTitleLabel.frame) + 8;
    } else {
        self.contentTitleLabel.frame = CGRectMake(64, 0, 0, 0);
        contentLabelY = CGRectGetMaxY(self.contentTitleLabel.frame);
    }
    CGSize contentLabelSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(self.selfW - 64 - 8, 120) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.contentLabel.font} context:nil].size;
    self.contentLabel.frame = CGRectMake(64, contentLabelY, contentLabelSize.width, contentLabelSize.height);
    
    NSString *share_image = self.row[@"share_image"];
    if (![share_image containsString:@"http"]) {
        share_image = [NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], self.row[@"share_image"]];
    }
    
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:share_image] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
       
        CGFloat imageViewW = 120;
        CGFloat imageViewH = 0.0;
        if (image.size.width < 120) {
            imageViewW = image.size.width;
            imageViewH = image.size.height;
        } else {
            imageViewH = imageViewW * (image.size.height / image.size.width);
        }
        
        self.contentImageView.frame = CGRectMake(64, CGRectGetMaxY(self.contentLabel.frame) + 8, imageViewW, imageViewH);
        
        CGFloat forum_nameLabelH = (self.sourceType == 1) ? 0 : 14;
        self.forum_nameLabel.text = self.row[@"forum_name"];
        CGSize forum_nameLabelSize = [self.forum_nameLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 64) * 0.2, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.forum_nameLabel.font} context:nil].size;
        self.forum_nameLabel.frame = CGRectMake(64, CGRectGetMaxY(self.contentImageView.frame) + 8, forum_nameLabelSize.width, forum_nameLabelH);
        
        CGFloat bottomLineViewY = (self.sourceType == 1) ? CGRectGetMaxY(self.contentImageView.frame) + 32 : CGRectGetMaxY(self.forum_nameLabel.frame) + 8;
        self.bottomLineView.frame = CGRectMake((CGRectGetMaxX(self.headerImageView.frame) + 8), bottomLineViewY, self.selfW - (CGRectGetMaxX(self.headerImageView.frame) + 8), 1);
        
        self.cellContentView.frame = CGRectMake(0, CGRectGetMaxY(self.cellHeaderView.frame), self.selfW, CGRectGetMaxY(self.bottomLineView.frame));
        
        NSString *creatTime = [XCZTimeTools timeWithTimeIntervalString:self.row[@"create_time"]];
        NSString *showTime = [XCZTimeTools formateDate:creatTime withFormate:@"yyyy-MM-dd HH:mm:ss"];
        
        self.timeLabel.text = [NSString stringWithFormat:@"时间: %@", showTime];
        CGFloat timeLabelX = (self.sourceType == 1) ? 64 : (CGRectGetMaxX(self.forum_nameLabel.frame) + 8);
        self.timeLabel.frame = CGRectMake(timeLabelX, self.bottomLineView.frame.origin.y - 8 - 10, 200, 10);
        
        self.praiseTextLabel.text = self.row[@"goods"];
        CGFloat praiseTextLabelH = 10;
        CGFloat praiseTextLabelW = 24;
        CGFloat praiseTextLabelY = self.bottomLineView.frame.origin.y - 8 - praiseTextLabelH;
        CGFloat praiseTextLabelX = self.selfW - 16 - praiseTextLabelW;
        self.praiseTextLabel.frame = CGRectMake(praiseTextLabelX, praiseTextLabelY, praiseTextLabelW, praiseTextLabelH);
        
        CGFloat praiseImageViewH = praiseTextLabelH;
        CGFloat praiseImageViewW = praiseImageViewH;
        CGFloat praiseImageViewY = praiseTextLabelY;
        CGFloat praiseImageViewX = praiseTextLabelX - praiseImageViewW - 4;
        self.praiseImageView.frame = CGRectMake(praiseImageViewX, praiseImageViewY, praiseImageViewW, praiseImageViewH);
        
        self.commentTextLabel.text = self.row[@"replies"];
        CGFloat commentTextLabelH = praiseTextLabelH;
        CGFloat commentTextLabelW = praiseTextLabelW;
        CGFloat commentTextLabelY = praiseTextLabelY;
        CGFloat commentTextLabelX = praiseImageViewX - commentTextLabelW - 24;
        self.commentTextLabel.frame = CGRectMake(commentTextLabelX, commentTextLabelY, commentTextLabelW, commentTextLabelH);
        
        CGFloat commentImageViewH = praiseTextLabelH;
        CGFloat commentImageViewW = praiseImageViewH;
        CGFloat commentImageViewY = praiseTextLabelY;
        CGFloat commentImageViewX = commentTextLabelX - commentImageViewW - 4;
        self.commentImageView.frame = CGRectMake(commentImageViewX, commentImageViewY, commentImageViewW, commentImageViewH);
        
        CGFloat cellBHeight = CGRectGetMaxY(self.cellContentView.frame);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZCircleTableViewLeafletsImageCellBHeightToVC" object:nil userInfo:@{@"cellBHeight": @(cellBHeight)}];
        });
       
    }];
}

- (void)cellHeaderViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleTableViewLeafletsImageCell:cellHeaderViewDidClick:)]) {
        [self.delegate circleTableViewLeafletsImageCell:self cellHeaderViewDidClick:self.row];
    }
}

- (void)cellContentViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleTableViewLeafletsImageCell:cellContentViewDidClick:)]) {
        [self.delegate circleTableViewLeafletsImageCell:self cellContentViewDidClick:self.row];
    }
}



@end
