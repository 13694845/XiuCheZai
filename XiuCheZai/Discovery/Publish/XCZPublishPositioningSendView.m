//
//  XCZPublishPositioningSendView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/4.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishPositioningSendView.h"
#import "DiscoveryConfig.h"

@interface XCZPublishPositioningSendView()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UIImageView *arrowView;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation XCZPublishPositioningSendView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 22, 22)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:iconView];
        self.iconView = iconView;
        
        CGFloat arrowViewW = 6;
        CGFloat arrowViewH = 10;
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 16 - arrowViewW, (frame.size.height - arrowViewH) * 0.5, arrowViewW, arrowViewH)];
        arrowView.image = [UIImage imageNamed:@"bbs_rightArrow"];
        arrowView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:arrowView];
        self.arrowView = arrowView;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 8, 0, 50, frame.size.height)];
        nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 8, 0, arrowView.frame.origin.x - 15 - CGRectGetMaxX(nameLabel.frame) - 8, frame.size.height)];
        textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        textLabel.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:textLabel];
        textLabel.textAlignment = NSTextAlignmentRight;
        self.textLabel = textLabel;
        
        CGFloat lineViewH = 1.0;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - lineViewH, frame.size.width, lineViewH)];
        lineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [self addSubview:lineView];
        self.lineView = lineView;
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    self.iconView.image = [UIImage imageNamed:[row objectForKey:@"icon"]];
    self.nameLabel.text = [row objectForKey:@"name"];
}

- (void)setTextShow:(NSString *)textShow
{
    _textShow = textShow;
    
    self.textLabel.text = textShow;
}

@end
