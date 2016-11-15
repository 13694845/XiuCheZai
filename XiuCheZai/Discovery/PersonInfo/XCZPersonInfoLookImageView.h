//
//  XCZPersonInfoLookImageView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPersonInfoLookImageView;


static NSString *const kPersonBannerImageKey = @"Personimg_src";
static NSString *const kPersonBannerURLKey = @"Personlink";

@protocol XCZPersonInfoLookImageViewDataSource <NSObject>

- (NSArray *)bannersForBannerView:(XCZPersonInfoLookImageView *)bannerView;

@end

@protocol XCZPersonInfoLookImageViewDelegate <NSObject>

- (void)bannerView:(XCZPersonInfoLookImageView *)bannerView currentImageNum:(int)currentImageNum currentImage:(UIImage *)image;
- (void)bannerView:(XCZPersonInfoLookImageView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo;

@end

@interface XCZPersonInfoLookImageView : UIView

@property (weak, nonatomic) id <XCZPersonInfoLookImageViewDelegate> delegate;
@property (weak, nonatomic) id <XCZPersonInfoLookImageViewDataSource> dataSource;

- (void)reloadData;

@end
