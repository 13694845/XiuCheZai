//
//  XCZMessageHeaderView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageHeaderView.h"
#import "XCZPersonInfoHeaderOtherBtn.h"
#import "XCZConfig.h"
#import "UIButton+WebCache.h"
#define XCZMessageHeaderViewDefaultSignLabelText @"您还没留下您的签名"

@interface XCZMessageHeaderView()

@property (nonatomic, weak) UIButton *avatarBtn;
@property (nonatomic, weak) UIImageView *vipImgView;
@property (nonatomic, weak) UILabel *userNameLabel;
@property (nonatomic, weak) UILabel *signLabel;
@property (nonatomic, weak) UIButton *signBtn;

@property(nonatomic, weak)UIView *headerOtherView;
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *integralBtn;
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *attentionMeBtn;
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *meAttentionBtn;
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *attentionClubBtn;

@end

@implementation XCZMessageHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat avatarBackViewWH = 72;
        CGFloat avatarBackViewX = (frame.size.width - avatarBackViewWH) * 0.5;
        CGFloat avatarBackViewY = 64 + 12;
        UIView *avatarBackView = [[UIView alloc] initWithFrame:CGRectMake(avatarBackViewX, avatarBackViewY, avatarBackViewWH, avatarBackViewWH)];
        avatarBackView.userInteractionEnabled = NO;
        avatarBackView.layer.cornerRadius = avatarBackViewWH * 0.5;
        avatarBackView.layer.masksToBounds = YES;
        avatarBackView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
        [self addSubview:avatarBackView];
        
        CGFloat avatarBtnWH = 72 - 7;
        CGFloat avatarBtnX = 3.5;
        CGFloat avatarBtnY = 3.5;
        UIButton *avatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(avatarBtnX, avatarBtnY, avatarBtnWH, avatarBtnWH)];
        avatarBtn.layer.cornerRadius = avatarBtnWH * 0.5;
        avatarBtn.layer.masksToBounds = YES;
        [avatarBtn setBackgroundImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"] forState:UIControlStateNormal];
        [avatarBackView addSubview:avatarBtn];
        self.avatarBtn = avatarBtn;
    
        CGFloat vipImgViewWH = 18;
        CGFloat vipImgViewX = CGRectGetMaxX(avatarBackView.frame) - vipImgViewWH;
        CGFloat vipImgViewY = CGRectGetMaxY(avatarBackView.frame) - vipImgViewWH;
        UIImageView *vipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(vipImgViewX, vipImgViewY, vipImgViewWH, vipImgViewWH)];
        vipImgView.backgroundColor = [UIColor yellowColor];
        vipImgView.layer.cornerRadius = vipImgViewWH * 0.5;
        vipImgView.layer.masksToBounds = YES;
        [self addSubview:vipImgView];
        self.vipImgView = vipImgView;
        
        CGFloat userNameLabelH = 14;
        CGFloat userNameLabelW = frame.size.width;
        CGFloat userNameLabelX = 0;
        CGFloat userNameLabelY = CGRectGetMaxY(avatarBackView.frame) + 12;
        UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userNameLabelX, userNameLabelY, userNameLabelW, userNameLabelH)];
        userNameLabel.text = @"用户名";
        userNameLabel.textColor = [UIColor whiteColor];
        userNameLabel.font = [UIFont systemFontOfSize:18];
        userNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:userNameLabel];
        self.userNameLabel = userNameLabel;
        
        UILabel *signLabel = [[UILabel alloc] init];
        signLabel.userInteractionEnabled = YES;
        signLabel.text = XCZMessageHeaderViewDefaultSignLabelText;
        signLabel.textColor = [UIColor whiteColor];
        signLabel.font = [UIFont systemFontOfSize:14];
        CGSize signLabelSize = [signLabel.text boundingRectWithSize:CGSizeMake(frame.size.width * 0.8, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : signLabel.font} context:nil].size;
        CGFloat signLabelX = (frame.size.width - signLabelSize.height - signLabelSize.width) * 0.5;
        CGFloat signLabelY = CGRectGetMaxY(userNameLabel.frame) + 12;
        signLabel.frame = CGRectMake(signLabelX, signLabelY, signLabelSize.width, signLabelSize.height);
        [self addSubview:signLabel];
        self.signLabel = signLabel;
        
        CGFloat signBtnWH = signLabelSize.height;
        CGFloat signBtnX = (frame.size.width - signBtnWH) * 0.5 + signLabel.bounds.size.width * 0.5;
        CGFloat signBtnY = signLabel.frame.origin.y;
        UIButton *signBtn = [[UIButton alloc] initWithFrame:CGRectMake(signBtnX, signBtnY, signBtnWH, signBtnWH)];
        [signBtn setImage:[UIImage imageNamed:@"bbs_signature"] forState:UIControlStateNormal];
        signBtn.backgroundColor = [UIColor whiteColor];
        signBtn.layer.cornerRadius = signBtnWH * 0.5;
        signBtn.layer.masksToBounds = YES;
        signBtn.layer.borderWidth = 0.5;
        signBtn.layer.borderColor = [UIColor colorWithRed:229/255.0 green:21/255.0 blue:45/255.0 alpha:1.0].CGColor;
        signBtn.userInteractionEnabled = YES;
        [self addSubview:signBtn];
        self.signBtn = signBtn;
        
        // 3.headerOtherView
        CGFloat otherBtnH = 32;
        UIView *headerOtherView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signBtn.frame) + 16, frame.size.width, otherBtnH)];
        [self addSubview:headerOtherView];
        self.headerOtherView = headerOtherView;
        CGFloat otherBtnW = (frame.size.width + 1) * 0.25;
        
        /** 3.2.积分按钮 */
        XCZPersonInfoHeaderOtherBtn *integralBtn = [[XCZPersonInfoHeaderOtherBtn alloc] initWithFrame:CGRectMake(0, 0, otherBtnW, otherBtnH)];
        integralBtn.tag = 0;
        integralBtn.ziLabel.text = @"奖励分";
        integralBtn.valueLabel.text = @"0";
        integralBtn.ziLabel.textColor = [UIColor whiteColor];
        integralBtn.valueLabel.textColor = [UIColor whiteColor];
        integralBtn.ziLabel.font = [UIFont systemFontOfSize:14];
        integralBtn.valueLabel.font = [UIFont systemFontOfSize:16];
        [headerOtherView addSubview:integralBtn];
        self.integralBtn = integralBtn;
        
        /** 3.3.关注他人数按钮 */
        XCZPersonInfoHeaderOtherBtn *attentionMeBtn = [[XCZPersonInfoHeaderOtherBtn alloc] initWithFrame:CGRectMake(otherBtnW, 0, otherBtnW, otherBtnH)];
        attentionMeBtn.tag = 1;
        attentionMeBtn.ziLabel.text = @"关注TA的";
        attentionMeBtn.valueLabel.text = @"0";
        attentionMeBtn.ziLabel.textColor = [UIColor whiteColor];
        attentionMeBtn.valueLabel.textColor = [UIColor whiteColor];
        attentionMeBtn.ziLabel.font = [UIFont systemFontOfSize:14];
        attentionMeBtn.valueLabel.font = [UIFont systemFontOfSize:16];
        [headerOtherView addSubview:attentionMeBtn];
        self.attentionMeBtn = attentionMeBtn;

        /** 3.5.他关注的人数按钮 */
        XCZPersonInfoHeaderOtherBtn *meAttentionBtn = [[XCZPersonInfoHeaderOtherBtn alloc] initWithFrame:CGRectMake(otherBtnW * 2, 0, otherBtnW, otherBtnH)];
        meAttentionBtn.tag = 3;
        meAttentionBtn.ziLabel.text = @"TA关注的";
        meAttentionBtn.valueLabel.text = @"0";
        meAttentionBtn.ziLabel.textColor = [UIColor whiteColor];
        meAttentionBtn.valueLabel.textColor = [UIColor whiteColor];
        meAttentionBtn.ziLabel.font = [UIFont systemFontOfSize:14];
        meAttentionBtn.valueLabel.font = [UIFont systemFontOfSize:16];
        [headerOtherView addSubview:meAttentionBtn];
        self.meAttentionBtn = meAttentionBtn;
        
        /** 3.6.club按钮 */
        XCZPersonInfoHeaderOtherBtn *attentionClubBtn = [[XCZPersonInfoHeaderOtherBtn alloc] initWithFrame:CGRectMake(otherBtnW * 3, 0, otherBtnW, otherBtnH)];
        attentionClubBtn.tag = 4;
        attentionClubBtn.ziLabel.text = @"车友会";
        attentionClubBtn.valueLabel.text = @"0";
        attentionClubBtn.ziLabel.textColor = [UIColor whiteColor];
        attentionClubBtn.valueLabel.textColor = [UIColor whiteColor];
        attentionClubBtn.ziLabel.font = [UIFont systemFontOfSize:14];
        attentionClubBtn.valueLabel.font = [UIFont systemFontOfSize:16];
        [headerOtherView addSubview:attentionClubBtn];
        self.attentionClubBtn = attentionClubBtn;
        
        [signLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signDidClick)]];
        [signBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signDidClick)]];
        
        [attentionMeBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [hasPraiseBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [meAttentionBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [attentionClubBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setUserDict:(NSDictionary *)userDict
{
    _userDict = userDict;
    
    NSString *avatar;
    if ([userDict[@"avatar"] containsString:@"http"]) {
        avatar = userDict[@"avatar"];
    } else {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], userDict[@"avatar"]];
    }
    [self.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    NSDictionary *pointsDict = [self pointsToName:userDict[@"points"]];
    self.vipImgView.image = pointsDict[@"image"];
     self.userNameLabel.text = ((NSString *)userDict[@"nick"]).length ? userDict[@"nick"] : userDict[@"login_name"];
    self.signLabel.text = ((NSString *)userDict[@"remark"]).length ? userDict[@"remark"] : XCZMessageHeaderViewDefaultSignLabelText;
    [self computeSignSize];
    
    self.integralBtn.valueLabel.text = userDict[@"points"];
    self.attentionMeBtn.valueLabel.text = userDict[@"bgz"];
    self.meAttentionBtn.valueLabel.text = userDict[@"gz"];
    self.attentionClubBtn.valueLabel.text = userDict[@"num"];
}

- (void)computeSignSize
{
    CGRect signLabelRect = self.signLabel.frame;
    signLabelRect.size.width = [self.signLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width * 0.8, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.signLabel.font} context:nil].size.width;
    signLabelRect.origin.x = (self.bounds.size.width - signLabelRect.size.height - signLabelRect.size.width) * 0.5;
    self.signLabel.frame = signLabelRect;
    
    CGRect signBtnRect = self.signBtn.frame;
    signBtnRect.origin.x = (self.bounds.size.width - signBtnRect.size.width) * 0.5 + self.signLabel.bounds.size.width * 0.5;
    self.signBtn.frame = signBtnRect;
}

- (void)signDidClick
{
    if ([self.delegate respondsToSelector:@selector(messageHeaderView:signDidClick:)]) {
        [self.delegate messageHeaderView:self signDidClick:self.signLabel];
    }
}

- (void)otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)btn
{
    if ([self.delegate respondsToSelector:@selector(messageHeaderView:otherBtnDidClick:)]) {
        [self.delegate messageHeaderView:self otherBtnDidClick:btn];
    }
}

- (NSDictionary *)pointsToName:(NSString *)points
{
    long long pointsLongLong = [points longLongValue];
    NSString *name;
    UIImage *image;
    if (pointsLongLong <= 49) {
        name = @"新手上路";
        image = [UIImage imageNamed:@"bbs_vip1"];
    } else if (pointsLongLong >= 50 && pointsLongLong <= 149) {
        name = @"初级会员";
        image = [UIImage imageNamed:@"bbs_vip2"];
    } else if (pointsLongLong >= 150 && pointsLongLong <= 299) {
        name = @"三星会员";
        image = [UIImage imageNamed:@"bbs_vip3"];
    } else if (pointsLongLong >= 300 && pointsLongLong <= 499) {
        name = @"支柱会员";
        image = [UIImage imageNamed:@"bbs_vip4"];
    } else if (pointsLongLong >= 500 && pointsLongLong <= 1049) {
        name = @"青铜长老";
        image = [UIImage imageNamed:@"bbs_vip5"];
    } else if (pointsLongLong >= 1050 && pointsLongLong <= 3899) {
        name = @"白银长老";
        image = [UIImage imageNamed:@"bbs_vip6"];
    } else if (pointsLongLong >= 3900 && pointsLongLong <= 6799) {
        name = @"黄金长老";
        image = [UIImage imageNamed:@"bbs_vip7"];
    } else if (pointsLongLong >= 6800 && pointsLongLong <= 10499) {
        name = @"白金长老";
        image = [UIImage imageNamed:@"bbs_vip8"];
    } else if (pointsLongLong >= 10500) {
        name = @"社区元老";
        image = [UIImage imageNamed:@"bbs_vip9"];
    }
    return @{@"name":name, @"image":image};
}

@end
