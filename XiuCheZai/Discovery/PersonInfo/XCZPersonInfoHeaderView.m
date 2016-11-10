//
//  XCZPersonInfoHeaderView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoHeaderView.h"
#import "XCZPersonInfoHeaderOtherBtn.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "DiscoveryConfig.h"
#import "XCZCityManager.h"

@interface XCZPersonInfoHeaderView()

// 1.图片部分
/** 1.pictureImageView */
@property(nonatomic, weak)UIImageView *pictureImageView;
/** 1.1pictureBottomView */
@property(nonatomic, weak)UIView *pictureBottomView;
/** 1.2是否认证Label */
@property(nonatomic, weak)UILabel *authenticateLabel;
/** 1.3logoImageView */
@property(nonatomic, weak)UIImageView *logoImageView;
/** 1.4汽车型号Label */
@property(nonatomic, weak)UILabel *typeLabel;

// 2.车主信息部分
// 2.infoView
@property(nonatomic, weak)UIView *infoView;
/** 2.1.用户头像 */
@property(nonatomic, weak)UIImageView *infoIconView;
/** 2.2.用户等级 */
@property(nonatomic, weak)UIImageView *vipIconView;
@property(nonatomic, weak)UILabel *userLavelLabel;
/** 2.3.车主字 */
@property(nonatomic, weak)UILabel *userZiLabel;
/** 2.4.车主值 */
@property(nonatomic, weak)UILabel *userValueLabel;
/** 2.5.城市字 */
@property(nonatomic, weak)UILabel *cityZiLabel;
/** 2.6.城市值 */
@property(nonatomic, weak)UILabel *cityValueLabel;
/** 2.7.身份字 */
@property(nonatomic, weak)UILabel *identityZiLabel;
/** 2.8.身份值 */
@property(nonatomic, weak)UILabel *identityValueLabel;
/** 2.9.签名字 */
@property(nonatomic, weak)UILabel *signZiLabel;
/** 2.10.签名值 */
@property(nonatomic, weak)UILabel *signValueLabel;
/** 2.11.分割线1 */
@property(nonatomic, weak)UIView *lineOneView;

// 3.headerOtherView
/** 3.headerOtherView */
@property(nonatomic, weak)UIView *headerOtherView;
/** 3.1.分割线2 */
@property(nonatomic, weak)UIView *lineTwoView;
/** 3.2.积分按钮 */
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *integralBtn;
/** 3.3.关注他人数按钮 */
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *attentionMeBtn;
///** 3.4.已点赞按钮 */
//@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *hasPraiseBtn;
/** 3.5.他关注的人数按钮 */
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *meAttentionBtn;
/** 3.6.club按钮 */
@property(nonatomic, weak)XCZPersonInfoHeaderOtherBtn *attentionClubBtn;

@property (nonatomic, strong) UIImage *imageHou;


@end

@implementation XCZPersonInfoHeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.图片部分
        UIImageView *pictureImageView = [[UIImageView alloc] init];
        pictureImageView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        [self addSubview:pictureImageView];
        self.pictureImageView = pictureImageView;
        
        UIView *pictureBottomView = [[UIView alloc] init];
        pictureBottomView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.83]; 
        [pictureImageView addSubview:pictureBottomView];
        self.pictureBottomView = pictureBottomView;
        
//        UILabel *authenticateLabel = [[UILabel alloc] init];
//        authenticateLabel.text = @"已认证";
//        authenticateLabel.font = [UIFont systemFontOfSize:10];
//        authenticateLabel.textColor = [UIColor whiteColor];
//        authenticateLabel.backgroundColor = [UIColor colorWithRed:231/155.0 green:156/255.0 blue:25/255.0 alpha:1.0];
//        authenticateLabel.textAlignment = NSTextAlignmentCenter;
//        [pictureBottomView addSubview:authenticateLabel];
//        self.authenticateLabel = authenticateLabel;
        
        UIImageView *logoImageView = [[UIImageView alloc] init];
        [pictureBottomView addSubview:logoImageView];
        self.logoImageView = logoImageView;
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.text = @"进口大众-尚酷-2.0t-2011豪华版";
        typeLabel.font = [UIFont systemFontOfSize:12];
        typeLabel.textColor = [UIColor whiteColor];
        [pictureBottomView addSubview:typeLabel];
        self.typeLabel = typeLabel;
        
        // 2.车主信息部分
        UIView *infoView = [[UIView alloc] init];
        infoView.backgroundColor = [UIColor whiteColor];
        [self addSubview:infoView];
        self.infoView = infoView;
        
        UIImageView *infoIconView = [[UIImageView alloc] init];
        infoIconView.layer.cornerRadius = 21;
        infoIconView.layer.masksToBounds = YES;
        [infoView addSubview:infoIconView];
        self.infoIconView = infoIconView;
        
        UIImageView *vipIconView = [[UIImageView alloc] init];
        [infoView addSubview:vipIconView];
        self.vipIconView = vipIconView;
        
        UILabel *userLavelLabel = [[UILabel alloc] init];
        userLavelLabel.text = @"用户等级";
        userLavelLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        userLavelLabel.font = [UIFont systemFontOfSize:12];
        userLavelLabel.numberOfLines = 2;
        [infoView addSubview:userLavelLabel];
        self.userLavelLabel = userLavelLabel;
        
        UILabel *userZiLabel = [[UILabel alloc] init];
        userZiLabel.text = @"车主:";
        userZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        userZiLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:userZiLabel];
        self.userZiLabel = userZiLabel;
        
        UILabel *userValueLabel = [[UILabel alloc] init];
        userValueLabel.text = @"";
        userValueLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        userValueLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:userValueLabel];
        self.userValueLabel = userValueLabel;
        
        UILabel *cityZiLabel = [[UILabel alloc] init];
        cityZiLabel.text = @"城市:";
        cityZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        cityZiLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:cityZiLabel];
        self.cityZiLabel = cityZiLabel;
        
        UILabel *cityValueLabel = [[UILabel alloc] init];
        cityValueLabel.text = @"";
        cityValueLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        cityValueLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:cityValueLabel];
        self.cityValueLabel = cityValueLabel;
        
        UILabel *identityZiLabel = [[UILabel alloc] init];
        identityZiLabel.text = @"身份:";
        identityZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        identityZiLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:identityZiLabel];
        self.identityZiLabel = identityZiLabel;
        
        UILabel *identityValueLabel = [[UILabel alloc] init];
        identityValueLabel.text = @"";
        identityValueLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        identityValueLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:identityValueLabel];
        self.identityValueLabel = identityValueLabel;
        
        UILabel *signZiLabel = [[UILabel alloc] init];
        signZiLabel.text = @"签名:";
        signZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        signZiLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:signZiLabel];
        self.signZiLabel = signZiLabel;
        
        UILabel *signValueLabel = [[UILabel alloc] init];
        signValueLabel.text = @"";
        signValueLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        signValueLabel.font = [UIFont systemFontOfSize:12];
        [infoView addSubview:signValueLabel];
        self.signValueLabel = signValueLabel;
        
        UIView *lineOneView = [[UIView alloc] init];
        lineOneView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        [infoView addSubview:lineOneView];
        self.lineOneView = lineOneView;
        
        // 3.headerOtherView
        UIView *headerOtherView = [[UIView alloc] init];
//        headerOtherView.backgroundColor = [UIColor orangeColor];
        [self addSubview:headerOtherView];
        self.headerOtherView = headerOtherView;
        
        UIView *lineTwoView = [[UIView alloc] init];
        lineTwoView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        [headerOtherView addSubview:lineTwoView];
        self.lineTwoView = lineTwoView;
        
        /** 3.2.积分按钮 */
        XCZPersonInfoHeaderOtherBtn *integralBtn = [[XCZPersonInfoHeaderOtherBtn alloc] init];
        integralBtn.tag = 0;
        integralBtn.ziLabel.text = @"奖励分";
        integralBtn.valueLabel.text = @"";
        [headerOtherView addSubview:integralBtn];
        self.integralBtn = integralBtn;
        
        /** 3.3.关注他人数按钮 */
        XCZPersonInfoHeaderOtherBtn *attentionMeBtn = [[XCZPersonInfoHeaderOtherBtn alloc] init];
        attentionMeBtn.tag = 1;
         attentionMeBtn.ziLabel.text = @"关注TA的";
        attentionMeBtn.valueLabel.text = @"";
        [headerOtherView addSubview:attentionMeBtn];
        self.attentionMeBtn = attentionMeBtn;
        
//        /** 3.4.已点赞按钮 */
//        XCZPersonInfoHeaderOtherBtn *hasPraiseBtn = [[XCZPersonInfoHeaderOtherBtn alloc] init];
//        hasPraiseBtn.tag = 2;
//        hasPraiseBtn.ziLabel.text = @"已点赞";
//        hasPraiseBtn.valueLabel.text = @"";
//        [headerOtherView addSubview:hasPraiseBtn];
//        self.hasPraiseBtn = hasPraiseBtn;
        
        /** 3.5.他关注的人数按钮 */
        XCZPersonInfoHeaderOtherBtn *meAttentionBtn = [[XCZPersonInfoHeaderOtherBtn alloc] init];
        meAttentionBtn.tag = 3;
        meAttentionBtn.ziLabel.text = @"TA关注的";
        meAttentionBtn.valueLabel.text = @"";
        [headerOtherView addSubview:meAttentionBtn];
        self.meAttentionBtn = meAttentionBtn;
        
        /** 3.6.club按钮 */
        XCZPersonInfoHeaderOtherBtn *attentionClubBtn = [[XCZPersonInfoHeaderOtherBtn alloc] init];
        attentionClubBtn.tag = 4;
        attentionClubBtn.ziLabel.text = @"车友会";
        attentionClubBtn.valueLabel.text = @"";
        [headerOtherView addSubview:attentionClubBtn];
        self.attentionClubBtn = attentionClubBtn;
        
        [attentionMeBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
//        [hasPraiseBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [meAttentionBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [attentionClubBtn addTarget:self action:@selector(otherBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setBanner:(NSDictionary *)banner
{
    _banner = banner;
    
    [self clearData];
    [self setupAttr];
    [self setupFrame];
}

- (void)clearData
{
    self.pictureImageView.image = [UIImage imageNamed:@""];
    self.authenticateLabel.text = @"";
    self.logoImageView.image = [UIImage imageNamed:@""];;
    self.typeLabel.text = @"";
    self.infoIconView.image = [UIImage imageNamed:@""];;
    self.userLavelLabel.text = @"";
    self.userValueLabel.text = @"";
    self.cityValueLabel.text = @"";
    self.identityValueLabel.text = @"";
    self.signValueLabel.text = @"";
    self.integralBtn.valueLabel.text = @"";
    self.attentionMeBtn.valueLabel.text = @"";
    self.meAttentionBtn.valueLabel.text = @"";
    self.attentionClubBtn.valueLabel.text = @"";
}

- (void)setupAttr
{
    NSDictionary *user = [_banner objectForKey:@"user"];
    // 1.图片部分
    if (((NSString *)user[@"car_image"]).length) {
        NSString *pictureImageViewURLStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], user[@"car_image"]];
        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:pictureImageViewURLStr]];
        UIImage *image = [UIImage imageWithData:data];
        [self cropImg:image];
        [self.pictureImageView setImage:self.imageHou];
    } else {
        [self.pictureImageView setImage:[UIImage imageNamed:@"mas_car.jpg"]];
    }
   
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], user[@"brand_logo"]]] placeholderImage:nil];
    if (!(((NSString *)user[@"car_image"]).length)) {
        self.typeLabel.text = @"这家伙很懒！未留下车型相关信息！";
    } else {
        self.typeLabel.text = user[@"car_name"];
    }
    
    // 2.车主信息部分
    [self.infoIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], user[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    NSDictionary *pointsDict = [self pointsToName:user[@"points"]];
    self.userLavelLabel.text = pointsDict[@"name"];
    self.vipIconView.image = pointsDict[@"image"];
    self.userValueLabel.text = ((NSString *)user[@"nick"]).length ? user[@"nick"] : user[@"login_name"];
    
    NSString *province_name = [XCZCityManager provinceNameForProvinceId:[user objectForKey:@"province_id"]];
    NSString *city_name = [XCZCityManager cityNameForCityId:[user objectForKey:@"city_id"]];
    NSString *area_name = [XCZCityManager townNameForTownId:[user objectForKey:@"area_id"]];

    if (area_name.length) {
        self.cityValueLabel.text = area_name; // 根据cityid来取城市
    } else {
        if (city_name.length) {
            self.cityValueLabel.text = city_name;
        } else {
            self.cityValueLabel.text = province_name;
        }
    }
    
    self.identityValueLabel.text = user[@"forum_name"];
    self.signValueLabel.text = user[@"remark"];
    
    // 3.积分等部分
    self.integralBtn.valueLabel.text = user[@"points"];
    self.attentionMeBtn.valueLabel.text = user[@"bgz"];
    self.meAttentionBtn.valueLabel.text = user[@"gz"];
    self.attentionClubBtn.valueLabel.text = user[@"num"];
}

- (void)setupFrame
{
    CGFloat selfW = self.selfW;
    // 1.图片部分
    int pictureImageViewH = selfW;
    self.pictureImageView.frame = CGRectMake(0, 0, selfW, pictureImageViewH);
    CGFloat pictureBottomViewH = 28;
    CGFloat pictureBottomViewW = selfW;
    self.pictureBottomView.frame = CGRectMake(0, pictureImageViewH - pictureBottomViewH, pictureBottomViewW, pictureBottomViewH);
    CGFloat authenticateLabelW = 40;
    CGFloat authenticateLabelH = 13;
    self.authenticateLabel.frame = CGRectMake(pictureBottomViewW - authenticateLabelW - 8, (pictureBottomViewH - authenticateLabelH) * 0.5, authenticateLabelW, authenticateLabelH);
    CGFloat logoImageViewH = 20;
    CGFloat logoImageViewW = logoImageViewH;
    self.logoImageView.frame = CGRectMake(8, (pictureBottomViewH - logoImageViewH) * 0.5, logoImageViewW, logoImageViewH);
    
    NSDictionary *user = [_banner objectForKey:@"user"];
    if (!(((NSString *)user[@"car_image"]).length)) {
        if (((NSString *)(user[@"brand_logo"])).length) {
            self.typeLabel.frame = CGRectMake(8 + 20 + 8, 0, selfW - (8 + logoImageViewW) - 16, pictureBottomViewH);
        } else {
            self.typeLabel.frame = CGRectMake(8, 0, selfW - (8 + logoImageViewW) - 16, pictureBottomViewH);
        }
    } else {
        self.typeLabel.frame = CGRectMake(8 + 20 + 8, 0, selfW - (8 + logoImageViewW) - 16, pictureBottomViewH);
    }
    
    // 2.车主信息部分
    CGFloat infoViewH = 93;
    self.infoView.frame = CGRectMake(0, pictureImageViewH, selfW, infoViewH);
    self.infoIconView.frame = CGRectMake(16, 8, 40, 40);
    CGFloat vipIconViewWH = 13;
    self.vipIconView.frame = CGRectMake(CGRectGetMaxX(self.infoIconView.frame) - vipIconViewWH, CGRectGetMaxY(self.infoIconView.frame) - vipIconViewWH, vipIconViewWH, vipIconViewWH);
    self.userLavelLabel.frame = CGRectMake(25, 8 + 40 + 4, 34, 34);
    CGFloat userZiLabelX = 72;
    CGFloat userZiLabelY = 8;
    CGFloat userZiLabelW = 32;
    CGFloat userZiLabelH = 13;
    self.userZiLabel.frame =  CGRectMake(userZiLabelX, userZiLabelY, userZiLabelW, userZiLabelH);
    CGFloat cityZiLabelX = 72;
    CGFloat cityZiLabelY = userZiLabelY + userZiLabelH + 8;
    CGFloat cityZiLabelW = 32;
    CGFloat cityZiLabelH = 13;
    self.cityZiLabel.frame =  CGRectMake(cityZiLabelX, cityZiLabelY, cityZiLabelW, cityZiLabelH);
    CGFloat identityZiLabelX = 72;
    CGFloat identityZiLabelY = cityZiLabelY + cityZiLabelH + 8;
    CGFloat identityZiLabelW = 32;
    CGFloat identityZiLabelH = 13;
    self.identityZiLabel.frame =  CGRectMake(identityZiLabelX, identityZiLabelY, identityZiLabelW, identityZiLabelH);
    CGFloat signZiLabelX = 72;
    CGFloat signZiLabelY = identityZiLabelY + identityZiLabelH + 8;
    CGFloat signZiLabelW = 32;
    CGFloat signZiLabelH = 13;
    self.signZiLabel.frame =  CGRectMake(signZiLabelX, signZiLabelY, signZiLabelW, signZiLabelH);
    CGFloat userValueLabelX = userZiLabelX + userZiLabelW;
    CGFloat userValueLabelY = userZiLabelY;
    CGFloat userValueLabelW = selfW - userValueLabelX - 16;
    CGFloat userValueLabelH = userZiLabelH;
    self.userValueLabel.frame = CGRectMake(userValueLabelX, userValueLabelY, userValueLabelW, userValueLabelH);
    CGFloat cityValueLabelX = cityZiLabelX + cityZiLabelW;
    CGFloat cityValueLabelY = cityZiLabelY;
    CGFloat cityValueLabelW = selfW - cityValueLabelX - 16;
    CGFloat cityValueLabelH = cityZiLabelH;
    self.cityValueLabel.frame = CGRectMake(cityValueLabelX, cityValueLabelY, cityValueLabelW, cityValueLabelH);
    CGFloat identityValueLabelX = identityZiLabelX + identityZiLabelW;
    CGFloat identityValueLabelY = identityZiLabelY;
    CGFloat identityValueLabelW = selfW - identityValueLabelX - 16;
    CGFloat identityValueLabelH = identityZiLabelH;
    self.identityValueLabel.frame = CGRectMake(identityValueLabelX, identityValueLabelY, identityValueLabelW, identityValueLabelH);
    CGFloat signValueLabelX = signZiLabelX + signZiLabelW;
    CGFloat signValueLabelY = signZiLabelY;
    CGFloat signValueLabelW = selfW - signValueLabelX - 16;
    CGFloat signValueLabelH = signZiLabelH;
    self.signValueLabel.frame = CGRectMake(signValueLabelX, signValueLabelY, signValueLabelW, signValueLabelH);
    self.lineOneView.frame = CGRectMake(0, signValueLabelY + signValueLabelH + 8, selfW, 1.0);
    
    // headerOtherView
    self.headerOtherView.frame =  CGRectMake(0, pictureImageViewH + infoViewH + 8, selfW, 41);
    self.lineTwoView.frame = CGRectMake(0, 40, selfW, 1.0);
    CGFloat otherBtnW = (selfW + 1) * 0.25;
    CGFloat deatY = 1;
    self.integralBtn.frame = CGRectMake(0, 0, otherBtnW, self.headerOtherView.bounds.size.height);
    self.integralBtn.deatY = deatY;
    self.attentionMeBtn.frame = CGRectMake(otherBtnW, 0, otherBtnW, self.headerOtherView.bounds.size.height);
    self.attentionMeBtn.deatY = deatY;
    self.meAttentionBtn.frame = CGRectMake(otherBtnW * 2, 0, otherBtnW, self.headerOtherView.bounds.size.height);
    self.meAttentionBtn.deatY = deatY;
    self.attentionClubBtn.frame = CGRectMake(otherBtnW * 3, 0, otherBtnW, self.headerOtherView.bounds.size.height);
    self.attentionClubBtn.deatY = deatY;
}

- (void)otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)btn
{
    if ([self.delegate respondsToSelector:@selector(personInfoHeaderView:otherBtnDidClick:)]) {
        [self.delegate personInfoHeaderView:self otherBtnDidClick:btn];
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

-(void)cropImg:(UIImage *)image
{
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    CGFloat orgX = 0.0;
    CGFloat orgY = 0.0;
    if (image.size.width > image.size.height) {
        width = image.size.height;
        height = width;
        orgX = (image.size.width - height) * 0.5;
        orgY = 0;
    } else {
        width = image.size.width;
        height = width;
        orgX = 0;
        orgY = (image.size.height - width) * 0.5;
    }
    CGRect cropRect = CGRectMake(orgX, orgY, width, height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *nowImage = [UIImage imageWithCGImage:imageRef];
    self.imageHou = nowImage;
    CGImageRelease(imageRef);
}


@end





















