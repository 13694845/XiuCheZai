//
//  BannerView.h
//  XiuCheZai
//
//  Created by QSH on 16/1/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCZNewsBannerView;

static NSString *const kBannerImageKey = @"img_src";
static NSString *const kBannerURLKey = @"link";

@protocol XCZNewsBannerViewDataSource <NSObject>

- (NSArray *)bannersForBannerView:(XCZNewsBannerView *)bannerView;

@end

@protocol XCZNewsBannerViewDelegate <NSObject>

- (void)bannerView:(XCZNewsBannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo;

@end

@interface XCZNewsBannerView : UIView

@property (weak, nonatomic) id <XCZNewsBannerViewDelegate> delegate;
@property (weak, nonatomic) id <XCZNewsBannerViewDataSource> dataSource;

- (void)reloadData;

@end
