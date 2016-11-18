//
//  XCZClubCircleHeaderView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/23.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleHeaderView.h"
#import "UIImageView+WebCache.h"
#import "DiscoveryConfig.h"
#import "XCZConfig.h"

@interface XCZClubCircleHeaderView()

/** 1.clubOneView */
@property(nonatomic, weak)UIView *clubOneView;

/** 1.1 图标 */
@property(nonatomic, weak)UIImageView *iconView;
/** 1.2 名字 */
@property(nonatomic, weak)UILabel *nameLabel;
/** 1.3 今日话题字 */
@property(nonatomic, weak)UILabel *talkZiLabel;
/** 1.4 今日话题值 */
@property(nonatomic, weak)UILabel *talkValueLabel;
/** 1.5 关注人数字 */
@property(nonatomic, weak)UILabel *attentionZiLabel;
/** 1.6 关注人数值 */
@property(nonatomic, weak)UILabel *attentionValueLabel;
/** 1.7 添加按钮 */
@property(nonatomic, weak)UIButton *addBtn;
/** 1.8 分割线1 */
@property(nonatomic, weak)UIView *clubOneLineView;

/** 2.clubTwoView */
@property(nonatomic, weak)UIView *clubTwoView;
/** 2.1clubTwoViews数组 */
@property(nonatomic, strong)NSMutableArray *clubTwoViews;
/** 2.2被点击的按钮 */
@property(nonatomic, weak)UIButton *selectedBtn;



@end

@implementation XCZClubCircleHeaderView

- (NSMutableArray *)clubTwoViews
{
    if (!_clubTwoViews) {
        _clubTwoViews = [NSMutableArray array];
    }
    return _clubTwoViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
//        self.backgroundColor = [UIColor redColor];
        
        UIView *clubOneView = [[UIView alloc] init];
        clubOneView.backgroundColor = [UIColor whiteColor];
        [self addSubview:clubOneView];
        self.clubOneView = clubOneView;
        /** 1.1 图标 */
        UIImageView *iconView = [[UIImageView alloc] init];
        [clubOneView addSubview:iconView];
        self.iconView = iconView;
        /** 1.2 名字 */
        UILabel *nameLabel = [[UILabel alloc] init];
        [clubOneView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        /** 1.3 今日话题字 */
        UILabel *talkZiLabel = [[UILabel alloc] init];
        [clubOneView addSubview:talkZiLabel];
        self.talkZiLabel = talkZiLabel;
        /** 1.4 今日话题值 */
        UILabel *talkValueLabel = [[UILabel alloc] init];
        [clubOneView addSubview:talkValueLabel];
        self.talkValueLabel = talkValueLabel;
        /** 1.5 关注人数字 */
        UILabel *attentionZiLabel = [[UILabel alloc] init];
        [clubOneView addSubview:attentionZiLabel];
        self.attentionZiLabel = attentionZiLabel;
        /** 1.6 关注人数值 */
        UILabel *attentionValueLabel = [[UILabel alloc] init];
        [clubOneView addSubview:attentionValueLabel];
        self.attentionValueLabel = attentionValueLabel;
        
        /** 1.7 添加按钮 */
        UIButton *addBtn = [[UIButton alloc] init];
        [clubOneView addSubview:addBtn];
        self.addBtn = addBtn;
        /** 1.8 分割线1 */
        UIView *clubOneLineView = [[UIView alloc] init];
        clubOneLineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [clubOneView addSubview:clubOneLineView];
        self.clubOneLineView = clubOneLineView;
        
        UIView *clubTwoView = [[UIView alloc] init];
        clubTwoView.backgroundColor = [UIColor whiteColor];
        [self addSubview:clubTwoView];
        self.clubTwoView = clubTwoView;
        
        /** 2.1 clubTwoView中按钮的创建*/
        NSArray *titles = @[
                                @"话题",
                                @"精华",
                                @"成员"
                            ];
        for (int i=0; i<3; i++) {
            UIButton *btn = [[UIButton alloc] init];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [self clubTwoBtnAttr:btn];
            btn.tag = i;
            [self.clubTwoView addSubview:btn];
            [self.clubTwoViews addObject:btn];
        }
        
        // 按钮点击
        [clubOneView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubOneViewDidClick:)]];
        [addBtn addTarget:self action:@selector(addBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)setBanner:(NSDictionary *)banner
{
    _banner = banner;
    
    [self setupAttr];
    [self setupFrame];
    
}

- (void)setupAttr
{
    NSString *iconStr;
    if ([self.banner[@"forum_style"] containsString:@"http"]) {
        iconStr = self.banner[@"forum_style"];
    } else {
        iconStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], self.banner[@"forum_style"]];
    }
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    
    self.nameLabel.text = self.banner[@"forum_name"];
    self.talkZiLabel.text = @"今日话题";
    self.talkValueLabel.text = self.banner[@"num"];
    self.attentionZiLabel.text = @"关注人数";
    self.attentionValueLabel.text = self.banner[@"members"];
    
    if (_hasJoin) { // 如果已经加入
        self.addBtn.userInteractionEnabled = NO;
        [self.addBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    } else {
        self.addBtn.userInteractionEnabled = YES;
        [self.addBtn setImage:[UIImage imageNamed:@"bbs_circleAdd_green"] forState:UIControlStateNormal];
    }
    
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.talkZiLabel.font = [UIFont systemFontOfSize:10];
    self.talkValueLabel.font = [UIFont systemFontOfSize:10];
    self.attentionZiLabel.font = [UIFont systemFontOfSize:10];
    self.attentionValueLabel.font = [UIFont systemFontOfSize:10];
    
    self.nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
    self.talkZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    self.talkValueLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    self.attentionZiLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    self.attentionValueLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
}

- (void)setupFrame
{
    self.clubOneView.frame = CGRectMake(0, 0, self.bounds.size.width, 75);
    self.clubTwoView.frame = CGRectMake(0, CGRectGetMaxY(self.clubOneView.frame), self.bounds.size.width, 40);
    
    /** 1.1 图标 */
    self.iconView.frame = CGRectMake(16, 16, 42, 42);
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.height * 0.5;
    self.iconView.layer.masksToBounds = YES;
    /** 1.2 名字 */
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 120, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 8, self.iconView.frame.origin.y + 4, nameLabelSize.width, nameLabelSize.height);
    
    /** 1.3 今日话题字 */
    CGSize talkZiLabelSize = [self.talkZiLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 200, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.talkZiLabel.font} context:nil].size;
    self.talkZiLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 8, CGRectGetMaxY(self.nameLabel.frame) + 8, talkZiLabelSize.width, talkZiLabelSize.height);
  
    /** 1.4 今日话题值 */
    CGSize talkValueLabelSize = [self.talkValueLabel.text boundingRectWithSize:CGSizeMake(50, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.talkZiLabel.font} context:nil].size;
    self.talkValueLabel.frame = CGRectMake(CGRectGetMaxX(self.talkZiLabel.frame) + 8, CGRectGetMaxY(self.nameLabel.frame) + 8, talkValueLabelSize.width, talkValueLabelSize.height);
    
    /** 1.5 关注人数字 */
    CGSize attentionZiLabelSize = [self.attentionZiLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 200, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.attentionZiLabel.font} context:nil].size;
    self.attentionZiLabel.frame = CGRectMake((self.bounds.size.width - attentionZiLabelSize.width) * 0.5, CGRectGetMaxY(self.nameLabel.frame) + 8, attentionZiLabelSize.width, attentionZiLabelSize.height);
 
    /** 1.6 关注人数值 */
    CGSize attentionValueLabelSize = [self.attentionZiLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 200, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.attentionValueLabel.font} context:nil].size;
    self.attentionValueLabel.frame = CGRectMake(CGRectGetMaxX(self.attentionZiLabel.frame) + 8, CGRectGetMaxY(self.nameLabel.frame) + 8, attentionValueLabelSize.width, attentionValueLabelSize.height);
    
    /** 1.7 添加按钮 */
    CGFloat addBtnW = 39;
    CGFloat addBtnH = addBtnW;
    CGFloat addBtnX = self.bounds.size.width - 8 - addBtnW;
    CGFloat addBtnY = (self.clubOneView.bounds.size.height - 1 - addBtnH) * 0.5;
    self.addBtn.frame = CGRectMake(addBtnX, addBtnY, addBtnW, addBtnH);
    
    CGFloat clubOneLineViewW = self.bounds.size.width - 32;
    CGFloat clubOneLineViewH = 1;
    CGFloat clubOneLineViewY = self.clubOneView.bounds.size.height - clubOneLineViewH;
    CGFloat clubOneLineViewX = 16;
    self.clubOneLineView.frame = CGRectMake(clubOneLineViewX, clubOneLineViewY, clubOneLineViewW, clubOneLineViewH);
    
    int i = 0;
    CGFloat btnW = self.bounds.size.width / 3.0;
    CGFloat btnH = self.clubTwoView.bounds.size.height;
    CGFloat btnY = 0;
    for (UIButton *btn in self.clubTwoViews) {
        CGFloat btnX = i * btnW;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        if (!btn.tag) {
            [self btnDidClick:btn];
        }
        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        i++;
    }
}


/**
 *  设置clubTwoView属性
 */
- (void)clubTwoBtnAttr:(UIButton *)btn
{
    if (!btn.isSelected) { // 正常状态下属性
        btn.selected = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else { // 点击状态下属性
        btn.selected = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:[UIColor colorWithRed:232/255.0 green:37/255.0 blue:30/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
}

#pragma mark - 监听按钮点击等事件
- (void)btnDidClick:(UIButton *)btn
{
    if (btn.isSelected) {
        [self respondsDelegateClubTwoViewSubBtnDidClick:btn];
    }
    
    btn.selected = YES;
    self.selectedBtn.selected = NO;
    [self clubTwoBtnAttr:btn];
    [self clubTwoBtnAttr:self.selectedBtn];
    self.selectedBtn = btn;
}

- (void)clubOneViewDidClick:(UIGestureRecognizer *)grz
{
    UIView *clubOneView = grz.view;
    [self respondsDelegateClubOneViewDidClick:clubOneView];
}

- (void)addBtnDidClick:(UIButton *)addBtn
{
    [self respondsDelegateAddBtnDidClick:addBtn];
}


#pragma mark - 代理协议部分处理
- (void)respondsDelegateClubTwoViewSubBtnDidClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(clubCircleHeaderView:clubTwoViewSubBtnDidClick:)]) {
        [self.delegate clubCircleHeaderView:self clubTwoViewSubBtnDidClick:btn];
    }
}

- (void)respondsDelegateClubOneViewDidClick:(UIView *)clubOneView
{
    if ([self.delegate respondsToSelector:@selector(clubCircleHeaderView:clubOneViewDidClick:)]) {
        [self.delegate clubCircleHeaderView:self clubOneViewDidClick:clubOneView];
    }
}

- (void)respondsDelegateAddBtnDidClick:(UIButton *)addBtn
{
    if ([self.delegate respondsToSelector:@selector(clubCircleHeaderView:addBtnDidClick:)]) {
        [self.delegate clubCircleHeaderView:self addBtnDidClick:addBtn];
    }
}




@end
