//
//  XCZNewDetailRemarkCell.m
//  XiuCheZai
//
//  Created by QSH on 16/9/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewDetailRemarkRow.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "XCZNewDetailRemarkRowReplyView.h"
#import "DiscoveryConfig.h"
#import "XCZTimeTools.h"

@interface XCZNewDetailRemarkRow ()<XCZNewDetailRemarkRowReplyViewDelegate>


@property (nonatomic, weak) UIImageView *likeImgView;
@property (nonatomic, weak) UILabel *likeLabel;

@end

@implementation XCZNewDetailRemarkRow

- (void)setRemark:(NSDictionary *)remark
{
    _remark = remark;
    
    [self setupView];
}

- (void)setupView {
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginX, XCZNewDetailRemarkRowMarginY, 33, 33)];
    iconView.layer.cornerRadius = iconView.bounds.size.height * 0.5;
    iconView.layer.masksToBounds = YES;
    [iconView sd_setImageWithURL:[NSURL URLWithString:[self changeIconStr:_remark[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    [self addSubview:iconView];
    
    UILabel *login_nameLabel = [[UILabel alloc] init];
    login_nameLabel.text = ((NSString *)_remark[@"nick"]).length ? _remark[@"nick"] : _remark[@"login_name"];
    login_nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    login_nameLabel.font = [UIFont systemFontOfSize:12];
    CGSize login_nameLabelSize = [login_nameLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth - 80, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
    login_nameLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX, XCZNewDetailRemarkRowMarginY + 33 * 0.5 - login_nameLabelSize.height * 0.5, login_nameLabelSize.width, login_nameLabelSize.height);
    [self addSubview:login_nameLabel];
    self.height += XCZNewDetailRemarkRowMarginY + 33 * 0.5 - login_nameLabelSize.height * 0.5 + login_nameLabelSize.height;
    
    if (_remark[@"brand_logo"]) {
        UIImageView *brandsLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(login_nameLabel.frame) + 4, login_nameLabel.frame.origin.y, login_nameLabelSize.height, login_nameLabelSize.height)];
        [brandsLogoView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig baseURL], _remark[@"brand_logo"]]] placeholderImage:nil];
        brandsLogoView.layer.cornerRadius = brandsLogoView.bounds.size.height * 0.5;
        brandsLogoView.layer.masksToBounds = YES;
        [self addSubview:brandsLogoView];
    }
    
    UILabel *houseNameLabel = [[UILabel alloc] init];
    houseNameLabel.text = _remark[@"floor"];
    houseNameLabel.font = [UIFont systemFontOfSize:10];
    houseNameLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    CGSize houseNameLabelSize = [houseNameLabel.text boundingRectWithSize:CGSizeMake(100, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : houseNameLabel.font} context:nil].size;
    CGFloat houseNameLabelW = houseNameLabelSize.width;
    CGFloat houseNameLabelH = houseNameLabelSize.height;
    CGFloat houseNameLabelX = _fatherWidth - XCZNewDetailRemarkRowMarginX - houseNameLabelW;
    CGFloat houseNameLabelY = XCZNewDetailRemarkRowMarginY + 33 * 0.5 - houseNameLabelH * 0.5;
    houseNameLabel.frame = CGRectMake(houseNameLabelX, houseNameLabelY, houseNameLabelW, houseNameLabelH);
    [self addSubview:houseNameLabel];
    
    UIView *iconPartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _fatherWidth * 0.7, CGRectGetMaxY(iconView.frame))];
    iconPartView.backgroundColor = [UIColor clearColor];
    [self addSubview:iconPartView];
    [iconPartView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconPartViewDidClick)]];
    
    UILabel *reply_contentLabel = [[UILabel alloc] init];
    reply_contentLabel.numberOfLines = 0;
    reply_contentLabel.text = _remark[@"reply_content"];
    reply_contentLabel.textColor = kXCTITLECOLOR;
    reply_contentLabel.font = [UIFont systemFontOfSize:14];
    CGSize reply_contentLabelSize = [reply_contentLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth - (XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX + XCZNewDetailRemarkRowMarginX), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : reply_contentLabel.font} context:nil].size;
    reply_contentLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY * 2, reply_contentLabelSize.width, reply_contentLabelSize.height);
    self.height += reply_contentLabel.bounds.size.height + XCZNewDetailRemarkRowMarginY * 2;
    [self addSubview:reply_contentLabel];
    
    UILabel *reply_timeLabel = [[UILabel alloc] init];
    reply_timeLabel.text = [XCZTimeTools formateDate:[XCZTimeTools timeWithTimeIntervalString:_remark[@"reply_time"]] withFormate:@"YYYY-MM-dd HH:mm:ss"];
    reply_timeLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    reply_timeLabel.font = [UIFont systemFontOfSize:10];
    CGSize reply_timeLabelSize = [reply_timeLabel.text boundingRectWithSize:CGSizeMake((_fatherWidth - (XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX + XCZNewDetailRemarkRowMarginX)) * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : reply_timeLabel.font} context:nil].size;
    reply_timeLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY, reply_timeLabelSize.width, reply_timeLabelSize.height);
    [self addSubview:reply_timeLabel];
    
    // 回复view
    UIView *replyView = [[UIView alloc] init];
    [self addSubview:replyView];
    UIImageView *replyImgView = [[UIImageView alloc] init];
    replyImgView.image = [UIImage imageNamed:@"bbs_message"];
    CGFloat replyImgViewH = 10;
    CGFloat replyImgViewW = replyImgViewH;
    replyImgView.frame = CGRectMake(0, 1.5, replyImgViewW, replyImgViewH);
    [replyView addSubview:replyImgView];
    UILabel *replyLabel = [[UILabel alloc] init];
    replyLabel.text = _remark[@"replies"];
    replyLabel.font = [UIFont systemFontOfSize:10];
    replyLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    CGSize replyLabelSize = [replyLabel.text boundingRectWithSize:CGSizeMake(80, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : replyLabel.font} context:nil].size;
    CGFloat replyLabelW = replyLabelSize.width;
    CGFloat replyLabelH = replyLabelSize.height;
    replyLabel.frame = CGRectMake(replyImgViewW + 2, 0, replyLabelW, replyLabelH);
    [replyView addSubview:replyLabel];
    CGFloat replyViewW = replyLabelW + replyImgViewW;
    CGFloat replyViewX = _fatherWidth - XCZNewDetailRemarkRowMarginX - replyViewW;
    replyView.frame = CGRectMake(replyViewX, self.height + XCZNewDetailRemarkRowMarginY, replyViewW, replyImgViewH);
    
    // 点赞view
    UIView *likeView = [[UIView alloc] init];
    [self addSubview:likeView];
    UIImageView *likeImgView = [[UIImageView alloc] init];
    likeImgView.image = [UIImage imageNamed:@"bbs_like"];
    CGFloat likeImgViewH = 10;
    CGFloat likeImgViewW = replyImgViewH;
    likeImgView.frame = CGRectMake(0, 1.5, likeImgViewW, likeImgViewH);
    [likeView addSubview:likeImgView];
    self.likeImgView = likeImgView;
    
    UILabel *likeLabel = [[UILabel alloc] init];
    likeLabel.text =  _remark[@"goods"];
    likeLabel.font = [UIFont systemFontOfSize:10];
    likeLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    CGSize likeLabelSize = [likeLabel.text boundingRectWithSize:CGSizeMake(80, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : replyLabel.font} context:nil].size;
    CGFloat likeLabelW = likeLabelSize.width;
    CGFloat likeLabelH = likeLabelSize.height;
    likeLabel.frame = CGRectMake(likeImgViewW + 2, 0, likeLabelW, likeLabelH);
    [likeView addSubview:likeLabel];
    self.likeLabel = likeLabel;
    
    CGFloat likeViewW = likeLabelW + likeImgViewW;
    CGFloat likeViewX = _fatherWidth - XCZNewDetailRemarkRowMarginX - replyViewW - 3 * XCZNewDetailRemarkRowMarginX - likeViewW;
    likeView.frame = CGRectMake(likeViewX, self.height + XCZNewDetailRemarkRowMarginY, likeViewW, likeImgViewH);
    
    self.height += reply_timeLabelSize.height + XCZNewDetailRemarkRowMarginY;
    UIView *middleLineView = [[UIView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY, _fatherWidth - (XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX) - XCZNewDetailRemarkRowMarginX, 1.0)];
    middleLineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
    self.height += 1.0 + XCZNewDetailRemarkRowMarginY;
    [self addSubview:middleLineView];

    NSArray *reply_infoArray = _remark[@"reply_info"];
    CGFloat subViewRowX = XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX;
    CGFloat subViewRowW = _fatherWidth - (XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX + XCZNewDetailRemarkRowMarginX) - XCZNewDetailRemarkRowMarginX;
    
    if (reply_infoArray.count) {
    for (int i = 0; i<reply_infoArray.count; i++) {
        if (i<2) { // 回复内容这里只显示两条
            XCZNewDetailRemarkRowReplyView *subViewRow = [[XCZNewDetailRemarkRowReplyView alloc] init];
            subViewRow.delegate = self;
            subViewRow.tag = i;
            subViewRow.fatherWidth = subViewRowW;
            subViewRow.nameDict = @{@"nick": _remark[@"nick"], @"login_name": _remark[@"login_name"], @"user_id": _remark[@"user_id"]};
            subViewRow.reply_info = reply_infoArray[i];
            CGFloat subViewRowY = self.height;
            subViewRow.frame = CGRectMake(subViewRowX, subViewRowY, subViewRowW, subViewRow.height);
            self.height += subViewRow.height;
            [self addSubview:subViewRow];
        }
    }
    
    CGFloat moreBtnH = 15;
            if (reply_infoArray.count > 2) {
                UIButton *moreBtn = [[UIButton alloc] init];
                moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [moreBtn setTitle:@"查看更多评论" forState:UIControlStateNormal];
                [moreBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:82/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateNormal];
                CGFloat moreBtnW = 200;
                CGFloat moreBtnX = (_fatherWidth - moreBtnW) * 0.5;
                CGFloat moreBtnY = self.height + 16;
                moreBtn.frame = CGRectMake(moreBtnX, moreBtnY, moreBtnW, moreBtnH);
                [self addSubview:moreBtn];
                [moreBtn addTarget:self action:@selector(moreBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
            }
    
        self.height += XCZNewDetailRemarkRowMarginY;
        CGFloat bottomLineViewY;
        bottomLineViewY = (reply_infoArray.count > 2) ? (self.height += moreBtnH + 2 * XCZNewDetailRemarkRowMarginY) : (self.height += XCZNewDetailRemarkRowMarginY);
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX, bottomLineViewY, _fatherWidth - (XCZNewDetailRemarkRowMarginX + 33 + XCZNewDetailRemarkRowMarginX) - XCZNewDetailRemarkRowMarginX, 1.0)];
        bottomLineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
        self.height += 1.0;
        [self addSubview:bottomLineView];
    }
    
    
    [likeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeViewDidClick:)]];
    [replyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyViewDidClick:)]];
}

- (CGFloat)height {
    return _height;
}

#pragma mark - 监听事件
- (void)moreBtnDidClick:(UIButton *)moreBtn
{
    if ([self.delegate respondsToSelector:@selector(detailRemarkRow:detailsRemarkRowDidClick:)]) {
        [self.delegate detailRemarkRow:self detailsRemarkRowDidClick:moreBtn];
    }
}

- (void)iconPartViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(detailRemarkRow:iconPartViewDidClickWithUserId:)]) {
        [self.delegate detailRemarkRow:self iconPartViewDidClickWithUserId:self.remark[@"user_id"]];
    }
}

- (void)newDetailRemarkRowReplyView:(XCZNewDetailRemarkRowReplyView *)newDetailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id
{
    if ([self.delegate respondsToSelector:@selector(detailRemarkRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate detailRemarkRowReplyView:newDetailRemarkRowReplyView nameDidClickWithUserId:bbs_user_id];
    }
}

- (void)likeViewDidClick:(UIGestureRecognizer *)grz
{
    if ([self.delegate respondsToSelector:@selector(detailRemarkRow:likeViewDidClick:)]) {
        [self.delegate detailRemarkRow:self likeViewDidClick:@{@"likeImgView": self.likeImgView, @"likeLabel": self.likeLabel}];
    }
}

- (void)replyViewDidClick:(UIGestureRecognizer *)grz
{
    UIView *replyView = grz.view;
    if ([self.delegate respondsToSelector:@selector(detailRemarkRow:replyViewDidClick:)]) {
        [self.delegate detailRemarkRow:self replyViewDidClick:replyView];
    }
}

#pragma mark - 私有方法
/**
 *  头像地址处理
 */
- (NSString *)changeIconStr:(NSString *)iconStr
{
    NSString *avatar;
    if ([iconStr containsString:@"http"]) {
        avatar = iconStr;
    } else {
        if (iconStr.length) {
            if ([[iconStr substringToIndex:1] isEqualToString:@"/"]) {
                avatar = [NSString stringWithFormat:@"%@%@", [XCZConfig imgBaseURL], iconStr];
            } else {
                avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], iconStr];
            }
        } else {
            avatar = @"";
        }
    }
    return avatar;
}

@end

















