//
//  XCZCircleDetailRemarkRowReplyView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleDetailRemarkRowReplyView.h"
#import "DiscoveryConfig.h"

@implementation XCZCircleDetailRemarkRowReplyView

- (void)setReply_info:(NSDictionary *)reply_info
{
    _reply_info = reply_info;
    [self setupView];
}

- (void)setupView {
    //    NSLog(@"nameDict:%@, reply_info:%@", self.nameDict, self.reply_info);
    UILabel *login_nameLabel = [[UILabel alloc] init];
    login_nameLabel.userInteractionEnabled = YES;
    NSString *huifuNameText = ((NSString *)_nameDict[@"nick"]).length ? _nameDict[@"nick"]: _nameDict[@"login_name"];
    NSString *nameText = ((NSString *)_reply_info[@"nick"]).length ? _reply_info[@"nick"]: _reply_info[@"login_name"];
    login_nameLabel.font = [UIFont systemFontOfSize:12];
    login_nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    [self addSubview:login_nameLabel];
    
    CGFloat dangeKonggeLength = [self oneKonggeLength];
    int konggeNumber;
    if ([self.nameDict[@"user_id"] isEqualToString:self.reply_info[@"follow_user_id"]]) { // 为楼主
        login_nameLabel.text = [NSString stringWithFormat:@"%@          :", nameText];
        CGSize login_nameLabelSize = [nameText boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
        CGFloat louzhuLabelW = 25;
        login_nameLabel.frame = CGRectMake(0, XCZNewDetailRemarkRowMarginY, login_nameLabelSize.width + louzhuLabelW + 8 + 8, login_nameLabelSize.height);
        UILabel *louzhuLabel = [[UILabel alloc] init];
        louzhuLabel.textAlignment = NSTextAlignmentCenter;
        louzhuLabel.layer.cornerRadius = 3;
        louzhuLabel.layer.masksToBounds = YES;
        louzhuLabel.backgroundColor = [UIColor colorWithRed:229/255.0 green:21/255.0 blue:45/255.0 alpha:1.0];
        louzhuLabel.textColor = [UIColor whiteColor];
        louzhuLabel.text = @"楼主";
        louzhuLabel.font = [UIFont systemFontOfSize:10];
        CGFloat louzhuLabelH = login_nameLabel.bounds.size.height;
        louzhuLabel.frame = CGRectMake(login_nameLabelSize.width + 4, login_nameLabel.frame.origin.y, louzhuLabelW, louzhuLabelH);
        [self addSubview:louzhuLabel];
        
        CGFloat konggeNumberFloat = login_nameLabel.bounds.size.width / dangeKonggeLength;
        int konggeNumberInt = konggeNumberFloat;
        if ((konggeNumberFloat - konggeNumberInt)) {
            konggeNumber = konggeNumberInt;
        }
    } else {
        login_nameLabel.text = [NSString stringWithFormat:@"%@", nameText];
        CGSize login_nameLabelSize = [login_nameLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
        login_nameLabel.frame = CGRectMake(0, XCZNewDetailRemarkRowMarginY, login_nameLabelSize.width, login_nameLabelSize.height);
        
        UILabel *maohaoLabel = [[UILabel alloc] init];
        maohaoLabel.font = login_nameLabel.font;
        maohaoLabel.textColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0];
        maohaoLabel.text = @" :";
        maohaoLabel.frame = CGRectMake(CGRectGetMaxX(login_nameLabel.frame), login_nameLabel.frame.origin.y, 8, login_nameLabel.bounds.size.height);
        [self addSubview:maohaoLabel];
        
        CGFloat showLength = CGRectGetMaxX(maohaoLabel.frame) - login_nameLabel.frame.origin.x;
        CGFloat konggeNumberFloat = showLength / dangeKonggeLength;
        int konggeNumberInt = konggeNumberFloat;
        if ((konggeNumberFloat - konggeNumberInt)) {
            konggeNumber = konggeNumberInt;
        }
    }
    
//    NSLog(@"login_nameLabel:%@", login_nameLabel);
    [login_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login_nameLabelDidClick)]];
    
    NSString *konggeStr = [self setupKongge:konggeNumber];
    UILabel *remarkLabel = [[UILabel alloc] init];
    remarkLabel.numberOfLines = 0;
    remarkLabel.text = [NSString stringWithFormat:@"%@  %@", konggeStr, _reply_info[@"follow_content"]];
    remarkLabel.font = [UIFont systemFontOfSize:12];
    remarkLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    CGSize remarkLabelSize = [remarkLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : remarkLabel.font} context:nil].size;
    remarkLabel.frame = CGRectMake(0, XCZNewDetailRemarkRowMarginY, remarkLabelSize.width, remarkLabelSize.height);
    self.height = remarkLabelSize.height + XCZNewDetailRemarkRowMarginY;
    [self addSubview:remarkLabel];
    
}

- (CGFloat)height {
    return _height;
}

#pragma mark - 监听事件
- (void)login_nameLabelDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleDetailRemarkRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate circleDetailRemarkRowReplyView:self nameDidClickWithUserId:self.nameDict[@"user_id"]];
    }
}

- (void)beiHuifuLabelDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleDetailRemarkRowReplyView:nameDidClickWithUserId:)]) {
         [self.delegate circleDetailRemarkRowReplyView:self nameDidClickWithUserId:self.reply_info[@"follow_user_id"]];
    }
}

#pragma mark - 私有方法
/**
 *  计算单个空格长度
 */
- (CGFloat)oneKonggeLength
{
    NSString *kongge = @" ";
    CGSize konggeSize = [kongge boundingRectWithSize:CGSizeMake(500, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    return konggeSize.width;
}

- (NSString *)setupKongge:(int)konggeNumber
{
    NSString *konggeStr = @"";
    for (int i = 0; i<konggeNumber; i++) {
        konggeStr = [NSString stringWithFormat:@" %@", konggeStr];
    }
    return konggeStr;
}


@end
