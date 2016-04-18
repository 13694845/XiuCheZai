//
//  BannerView.h
//  XiuCheZai
//
//  Created by QSH on 16/1/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerView;

static NSString *const kBannerImageKey = @"img_src";
static NSString *const kBannerURLKey = @"link";

@protocol BannerDelegate <NSObject>

- (void)bannerView:(BannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo;

@end

@interface BannerView : UIView

@property (weak, nonatomic) id <BannerDelegate> delegate;

@end
