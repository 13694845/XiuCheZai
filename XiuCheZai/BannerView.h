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

@protocol BannerViewDataSource <NSObject>

- (NSArray *)bannersForBannerView:(BannerView *)bannerView;

@end

@protocol BannerViewDelegate <NSObject>

- (void)bannerView:(BannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo;

@end

@interface BannerView : UIView

@property (weak, nonatomic) id <BannerViewDelegate> delegate;
@property (weak, nonatomic) id <BannerViewDataSource> dataSource;

- (void)reloadData;

@end
