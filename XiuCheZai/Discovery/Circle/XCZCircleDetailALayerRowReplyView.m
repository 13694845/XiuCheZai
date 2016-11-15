//
//  XCZCircleDetailALayerRowReplyView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleDetailALayerRowReplyView.h"
#import "DiscoveryConfig.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZTimeTools.h"
#import "XCZEmotionLabel.h"

@interface XCZCircleDetailALayerRowReplyView()

@property (nonatomic, assign) long touxiangCount;

@end

@implementation XCZCircleDetailALayerRowReplyView

- (void)setReply_info:(NSDictionary *)reply_info
{
    _reply_info = reply_info;
    [self setupView];
}

- (void)setupView {
    UIImageView *loginImageView = [[UIImageView alloc] init];
    CGFloat loginImageViewH = 29;
    CGFloat loginImageViewW = loginImageViewH;
    CGFloat loginImageViewY = XCZNewDetailRemarkRowMarginY;
    loginImageView.frame = CGRectMake(0, loginImageViewY, loginImageViewW, loginImageViewH);
    [loginImageView sd_setImageWithURL:[NSURL URLWithString:[self changeIconStr:_reply_info[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    loginImageView.layer.cornerRadius = loginImageViewH * 0.5;
    loginImageView.layer.masksToBounds = YES;
    [self addSubview:loginImageView];
    self.height = loginImageViewY + loginImageViewH + XCZNewDetailRemarkRowMarginY;
    
    UILabel *login_nameLabel = [[UILabel alloc] init];
    NSString *nameText = ((NSString *)_reply_info[@"nick"]).length ? _reply_info[@"nick"]: _reply_info[@"login_name"];
    login_nameLabel.font = [UIFont systemFontOfSize:12];
    login_nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    [self addSubview:login_nameLabel];
    
    if ([self.nameDict[@"user_id"] isEqualToString:self.reply_info[@"follow_user_id"]]) { // 为楼主
        login_nameLabel.text = [NSString stringWithFormat:@"%@        ", nameText];
        CGSize login_nameLabelSize = [nameText boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
        CGFloat louzhuLabelW = 25;
        CGFloat login_nameLabelX = CGRectGetMaxX(loginImageView.frame) + XCZNewDetailRemarkRowMarginX;
        CGFloat login_nameLabelY = loginImageViewY + loginImageViewH * 0.5 - login_nameLabelSize.height * 0.5;
        login_nameLabel.frame = CGRectMake(login_nameLabelX, login_nameLabelY, login_nameLabelSize.width + louzhuLabelW + 8, login_nameLabelSize.height);
        UILabel *louzhuLabel = [[UILabel alloc] init];
        louzhuLabel.textAlignment = NSTextAlignmentCenter;
        louzhuLabel.layer.cornerRadius = 3;
        louzhuLabel.layer.masksToBounds = YES;
        louzhuLabel.backgroundColor = [UIColor colorWithRed:229/255.0 green:21/255.0 blue:45/255.0 alpha:1.0];
        louzhuLabel.textColor = [UIColor whiteColor];
        louzhuLabel.text = @"楼主";
        louzhuLabel.font = [UIFont systemFontOfSize:10];
        CGFloat louzhuLabelH = login_nameLabel.bounds.size.height;
        louzhuLabel.frame = CGRectMake(login_nameLabelX + login_nameLabelSize.width + 4, login_nameLabel.frame.origin.y, louzhuLabelW, louzhuLabelH);
        [self addSubview:louzhuLabel];
    } else {
        login_nameLabel.text = [NSString stringWithFormat:@"%@", nameText];
        CGSize login_nameLabelSize = [login_nameLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
        CGFloat login_nameLabelY = loginImageViewY + loginImageViewH * 0.5 - login_nameLabelSize.height * 0.5;
        login_nameLabel.frame = CGRectMake(loginImageViewW + XCZNewDetailRemarkRowMarginX, login_nameLabelY, login_nameLabelSize.width, login_nameLabelSize.height);
//        UILabel *huifuziLabel = [[UILabel alloc] init];
//        huifuziLabel.font = login_nameLabel.font;
//        huifuziLabel.textColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0];
//        huifuziLabel.text = @"回复";
//        huifuziLabel.frame = CGRectMake(loginImageViewW + XCZNewDetailRemarkRowMarginX, CGRectGetMaxY(loginImageView.frame) + XCZNewDetailRemarkRowMarginY, 25, login_nameLabel.bounds.size.height);
//        [self addSubview:huifuziLabel];
//        
//        UILabel *beiHuifuLabel = [[UILabel alloc] init];
//        beiHuifuLabel.userInteractionEnabled = YES;
//        beiHuifuLabel.text = huifuNameText;
//        beiHuifuLabel.font = login_nameLabel.font;
//        beiHuifuLabel.textColor = login_nameLabel.textColor;
//        CGSize beiHuifuLabelSize = [beiHuifuLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : beiHuifuLabel.font} context:nil].size;
//        beiHuifuLabel.frame = CGRectMake(CGRectGetMaxX(huifuziLabel.frame), huifuziLabel.frame.origin.y, beiHuifuLabelSize.width, beiHuifuLabelSize.height);
//        [self addSubview:beiHuifuLabel];
//        [beiHuifuLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beiHuifuLabelDidClick)]];
//        
//        UILabel *maohaoLabel = [[UILabel alloc] init];
//        maohaoLabel.font = login_nameLabel.font;
//        maohaoLabel.textColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0];
//        maohaoLabel.text = @":";
//        maohaoLabel.frame = CGRectMake(CGRectGetMaxX(beiHuifuLabel.frame), huifuziLabel.frame.origin.y, 8, login_nameLabel.bounds.size.height);
//        [self addSubview:maohaoLabel];
        
//        CGFloat showLength = CGRectGetMaxX(maohaoLabel.frame) - loginImageViewW - XCZNewDetailRemarkRowMarginX;
//        CGFloat konggeNumberFloat = showLength / dangeKonggeLength;
//        int konggeNumberInt = konggeNumberFloat;
//        if ((konggeNumberFloat - konggeNumberInt)) {
//            konggeNumber = konggeNumberInt;
//        }
    }
    
    UIView *iconPartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _fatherWidth * 0.7, CGRectGetMaxY(loginImageView.frame))];
    iconPartView.userInteractionEnabled = YES;
    [self addSubview:iconPartView];
    [iconPartView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconPartViewDidClick)]];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    timeLabel.text = [XCZTimeTools formateDate:[XCZTimeTools timeWithTimeIntervalString:_reply_info[@"follow_time"]] withFormate:@"YYYY-MM-dd HH:mm:ss"];
    CGFloat timeLabelW = _fatherWidth * 0.5;
    CGFloat timeLabelH = login_nameLabel.bounds.size.height;
    CGFloat timeLabelX = _fatherWidth - timeLabelW;
    CGFloat timeLabelY = login_nameLabel.frame.origin.y;
    timeLabel.frame = CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH);
    [self addSubview:timeLabel];

    UILabel *remarkLabel = [[UILabel alloc] init];
    remarkLabel.numberOfLines = 0;
    NSString *yfollow_content = [_reply_info[@"follow_content"] stringByReplacingOccurrencesOfString:@"#0A;" withString:@"\n"];
    NSAttributedString *attributeStr = [self changeRichText:yfollow_content];
    [remarkLabel setAttributedText:attributeStr];
    remarkLabel.font = [UIFont systemFontOfSize:12];
    remarkLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    CGSize remarkLabelSize = [remarkLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth - login_nameLabel.frame.origin.x, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : remarkLabel.font} context:nil].size;
    
    CGFloat remarkLabelX = login_nameLabel.frame.origin.x;
    remarkLabel.frame = CGRectMake(remarkLabelX, CGRectGetMaxY(loginImageView.frame) +XCZNewDetailRemarkRowMarginY, _fatherWidth - login_nameLabel.frame.origin.x + XCZNewDetailRemarkRowMarginX, remarkLabelSize.height);
    self.height += remarkLabelSize.height + XCZNewDetailRemarkRowMarginY;
    [self addSubview:remarkLabel];
    
}

- (CGFloat)height {
    return _height;
}

#pragma mark - 事件处理
- (void)iconPartViewDidClick
{
    [self delegateMethod:self.nameDict[@"user_id"]];
}

- (void)beiHuifuLabelDidClick
{
    if ([self.delegate respondsToSelector:@selector(circleDetailALayerRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate circleDetailALayerRowReplyView:self nameDidClickWithUserId:self.nameDict[@"user_id"]];
    }
}

- (void)delegateMethod:(NSString *)user_id
{
    if ([self.delegate respondsToSelector:@selector(circleDetailALayerRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate circleDetailALayerRowReplyView:self nameDidClickWithUserId:self.reply_info[@"follow_user_id"]];
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

/**
 *  计算单个空格长度
 */
- (CGFloat)oneKonggeLength
{
    NSString *kongge = @" ";
    CGSize konggeSize = [kongge boundingRectWithSize:CGSizeMake(500, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    return konggeSize.width;
}

/**
 *  返回空格字符串
 *  konggeNumber:空格个数
 */
- (NSString *)setupKongge:(int)konggeNumber
{
    NSString *konggeStr = @"";
    for (int i = 0; i<konggeNumber; i++) {
        konggeStr = [NSString stringWithFormat:@" %@", konggeStr];
    }
    return konggeStr;
}

- (NSAttributedString *)changeRichText:(NSString *)msg_content
{
    // 截取出表情字符串并放入数组中
    NSMutableArray *textArray = [NSMutableArray array];
    [self cutOutStringExpressionWithString:msg_content addtextArray:textArray]; // 截取头像放入数组中
    self.touxiangCount = textArray.count;
    NSMutableArray *texts = [NSMutableArray array];
    for (int index = 0; index<textArray.count;index++) {
        NSString *text = textArray[index];
        [text rangeOfString:@".png"];
        if (text && ![text isEqualToString:@""] && [text rangeOfString:@".png"].length) {
            [texts addObject:text];
        }
    }
    
    
    // 将textArray数组拼接成字符串
    NSMutableString *syTextStr = [NSMutableString string];
    for (NSString *textN in textArray) {
        [syTextStr appendString:textN];
    }
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.0;
    
    NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                NSFontAttributeName: [UIFont systemFontOfSize: 12]
                                };
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:syTextStr attributes:attrDict];
    // 创建attachment
    for (NSString *text in texts) {
        //        NSLog(@"texttexttext:%@", text);
        XCZTextAttachmentTwo *attachment = [[XCZTextAttachmentTwo alloc]init];
        attachment.img = text;
        attachment.bounds = CGRectMake(0, -4.0, 12 + 2, 12 + 2);
        NSAttributedString *textA = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange range = [[attributeStr string] rangeOfString:text];
        [attributeStr replaceCharactersInRange:range withAttributedString:textA];
    }
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, attributeStr.length)];
    
    return attributeStr;
}

/**
 *  截取头像放入数组中
 */
- (NSMutableArray *)cutOutStringExpressionWithString:(NSString *)attText addtextArray:(NSMutableArray *)textArray
{
    NSRange range = [attText rangeOfString:@"^"];
    if (range.length) {
        
        NSString *qTextH = [attText substringToIndex:range.location];
        [textArray addObject:qTextH];
        
        NSString *attTextH = [attText substringFromIndex:range.location + 1];
        NSRange rangeH = [attTextH rangeOfString:@"^"];
        if (rangeH.length) {
            NSString *attImageStr = [NSString stringWithFormat:@"%@.png", [attTextH substringToIndex:rangeH.location]];
            [textArray addObject:attImageStr];
            NSString *attStrH = [attTextH substringFromIndex:rangeH.location + 1];
            [self cutOutStringExpressionWithString:attStrH addtextArray:textArray];
        } else {
            if (attText) {
                [textArray addObject:attText];
            }
        }
    } else {
        if (attText) {
            [textArray addObject:attText];
        }
    }
    return textArray;
}


@end
