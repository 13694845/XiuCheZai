//
//  XCZNewDetailRemarkSubViewRow.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewDetailRemarkRowReplyView.h"
#import "DiscoveryConfig.h"
#import "XCZEmotionLabel.h"

@interface XCZNewDetailRemarkRowReplyView()

@property (nonatomic, assign) long touxiangCount;

@end

@implementation XCZNewDetailRemarkRowReplyView

- (void)setReply_info:(NSDictionary *)reply_info
{
    _reply_info = reply_info;
    [self setupView];
}

- (void)setupView {
    UILabel *login_nameLabel = [[UILabel alloc] init];
    login_nameLabel.userInteractionEnabled = YES;
    NSString *nameText = ((NSString *)_reply_info[@"nick"]).length ? _reply_info[@"nick"]: _reply_info[@"login_name"];
    login_nameLabel.font = [UIFont systemFontOfSize:12];
    login_nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    [self addSubview:login_nameLabel];
    
    CGFloat dangeKonggeLength = [self oneKonggeLength];
    int konggeNumber;
        login_nameLabel.text = [NSString stringWithFormat:@"%@", nameText];
        CGSize login_nameLabelSize = [nameText boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
        CGFloat louzhuLabelW = 0;
        login_nameLabel.frame = CGRectMake(0, XCZNewDetailRemarkRowMarginY, login_nameLabelSize.width + louzhuLabelW + 8, login_nameLabelSize.height);
        UILabel *louzhuLabel = [[UILabel alloc] init];
        louzhuLabel.textAlignment = NSTextAlignmentCenter;
        louzhuLabel.layer.cornerRadius = 3;
        louzhuLabel.layer.masksToBounds = YES;
        louzhuLabel.backgroundColor = [UIColor colorWithRed:229/255.0 green:21/255.0 blue:45/255.0 alpha:1.0];
        louzhuLabel.textColor = [UIColor whiteColor];
        louzhuLabel.text = @"";
        louzhuLabel.font = [UIFont systemFontOfSize:10];
        CGFloat louzhuLabelH = login_nameLabel.bounds.size.height;
        louzhuLabel.frame = CGRectMake(login_nameLabelSize.width, login_nameLabel.frame.origin.y, louzhuLabelW, louzhuLabelH);
        [self addSubview:louzhuLabel];
        
        UILabel *maohaoLabel = [[UILabel alloc] init];
        maohaoLabel.font = login_nameLabel.font;
        maohaoLabel.textColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0];
        maohaoLabel.text = @" :";
        maohaoLabel.frame = CGRectMake(CGRectGetMaxX(louzhuLabel.frame), login_nameLabel.frame.origin.y, 8, login_nameLabel.bounds.size.height);
        [self addSubview:maohaoLabel];

        CGFloat konggeNumberFloat = login_nameLabel.bounds.size.width / dangeKonggeLength;
        int konggeNumberInt = konggeNumberFloat;
        if ((konggeNumberFloat - konggeNumberInt)) {
            konggeNumber = konggeNumberInt;
        }
    
    [login_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login_nameLabelDidClick)]];

    UILabel *remarkLabel = [[UILabel alloc] init];
    remarkLabel.numberOfLines = 0;
    NSString *konggeStr = [self setupKongge:konggeNumber];
    
    NSString *yfollow_content = [_reply_info[@"follow_content"] stringByReplacingOccurrencesOfString:@"#0A;" withString:@"\n"];
    NSString *follow_content = [NSString stringWithFormat:@"%@  %@", konggeStr, yfollow_content];
    NSAttributedString *attributeStr = [self changeRichText:follow_content];
    [remarkLabel setAttributedText:attributeStr];
    
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
    if ([self.delegate respondsToSelector:@selector(newDetailRemarkRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate newDetailRemarkRowReplyView:self nameDidClickWithUserId:self.nameDict[@"user_id"]];
    }
}

- (void)beiHuifuLabelDidClick
{
    if ([self.delegate respondsToSelector:@selector(newDetailRemarkRowReplyView:nameDidClickWithUserId:)]) {
        [self.delegate newDetailRemarkRowReplyView:self nameDidClickWithUserId:self.reply_info[@"follow_user_id"]];
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
