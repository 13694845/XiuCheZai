//
//  XCZPublishTextPhoneBtnView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishTextPhoneButton.h"

@interface XCZPublishTextPhoneButton()

@property (nonatomic, strong) UIImage *imageHou;

@end

@implementation XCZPublishTextPhoneButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"bbs_photoBtnAdd"] forState:UIControlStateNormal];
//        self.contentMode = UIViewContentModeScaleAspectFit;
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setImageDict:(NSDictionary *)imageDict
{
    _imageDict = imageDict;

    [self cropImg:[imageDict objectForKey:@"image"]];
    [self setImage:self.imageHou forState:UIControlStateNormal];
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
