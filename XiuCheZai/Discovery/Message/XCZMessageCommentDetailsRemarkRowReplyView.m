//
//  XCZMessageCommentDetailsRemarkRowReplyView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageCommentDetailsRemarkRowReplyView.h"
#import "DiscoveryConfig.h"

@implementation XCZMessageCommentDetailsRemarkRowReplyView

- (void)setReply_info:(NSDictionary *)reply_info
{
    _reply_info = reply_info;
    [self setupView];
}

- (void)setupView {
    UILabel *login_nameLabel = [[UILabel alloc] init];
    login_nameLabel.text = [NSString stringWithFormat:@"%@:", _reply_info[@"login_name"]];
    login_nameLabel.font = [UIFont systemFontOfSize:12];
    login_nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
    CGSize login_nameLabelSize = [login_nameLabel.text boundingRectWithSize:CGSizeMake(_fatherWidth * 0.5, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : login_nameLabel.font} context:nil].size;
    login_nameLabel.frame = CGRectMake(0, XCZNewDetailRemarkRowMarginY, _fatherWidth, login_nameLabelSize.height);
    [self addSubview:login_nameLabel];
    
    NSString *konggeStr = [self setupKongge:login_nameLabel];
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

- (NSString *)setupKongge:(UILabel *)login_nameLabel
{
    NSString *konggeStr = @"";
    for (int i = 0; i<login_nameLabel.text.length; i++) {
        konggeStr = [NSString stringWithFormat:@"   %@", konggeStr];
    }
    return konggeStr;
}

- (CGFloat)height {
    return _height;
}

@end
