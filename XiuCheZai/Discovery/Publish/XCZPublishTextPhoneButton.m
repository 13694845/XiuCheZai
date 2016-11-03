//
//  XCZPublishTextPhoneBtnView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishTextPhoneButton.h"

@implementation XCZPublishTextPhoneButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"bbs_photoBtnAdd"] forState:UIControlStateNormal];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setImageDict:(NSDictionary *)imageDict
{
    _imageDict = imageDict;

    [self setImage:[imageDict objectForKey:@"image"] forState:UIControlStateNormal];
}

@end
